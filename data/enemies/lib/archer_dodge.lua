local behavior = {}

-- Behavior of an enemy that goes towards the
-- the hero if he sees him, and randomly walks otherwise.
-- The enemy has only one sprite.

-- Example of use from an enemy script:

-- local enemy = ...
-- local behavior = require("enemies/lib/towards_hero")
-- local properties = {
--   sprite = "enemies/globul",
--   life = 1,
--   damage = 2,
--   normal_speed = 32,
--   faster_speed = 32,
--   hurt_style = "normal",
--   push_hero_on_sword = false,
--   pushed_when_hurt = true,
--   ignore_obstacles = false,
--   obstacle_behavior = "flying",
--   detection_distance = 100,
--   movement_create = function()
--     local m = sol.movement.create("random_path")
--     return m
--   end
-- }
-- behavior:create(enemy, properties)

-- The properties parameter is a table.
-- All its values are optional except the sprite.

function behavior:create(enemy, properties)

  local children = {}

  local can_attack = true
  local can_dodge = true
  local going_hero = false
  local hero_detected
  local dist_hero
  local telm = sol.movement.create("straight")
  local dodging = false

  -- Set default properties.
  if properties.life == nil then
    properties.life = 2
  end
  if properties.damage == nil then
    properties.damage = 2
  end
  if properties.normal_speed == nil then
    properties.normal_speed = 32
  end
  if properties.faster_speed == nil then
    properties.faster_speed = 48
  end
  if properties.size_x == nil then
    properties.size_x = 16
  end
  if properties.size_y == nil then
    properties.size_y = 16
  end
  if properties.hurt_style == nil then
    properties.hurt_style = "normal"
  end
  if properties.pushed_when_hurt == nil then
    properties.pushed_when_hurt = true
  end
  if properties.push_hero_on_sword == nil then
    properties.push_hero_on_sword = false
  end
  if properties.ignore_obstacles == nil then
    properties.ignore_obstacles = false
  end
  if properties.detection_distance == nil then
    properties.detection_distance = 112
  end
  if properties.obstacle_behavior == nil then
    properties.obstacle_behavior = "normal"
  end
  if properties.projectile_breed == nil then
    properties.projectile_breed = "misc/octorok_stone"
  end
  if properties.attack_frequency == nil then
    properties.attack_frequency = 1500
  end
  if properties.explosion_consequence == nil then
    properties.explosion_consequence = 1
  end
  if properties.fire_consequence == nil then
    properties.fire_consequence = 1
  end
  if properties.sword_consequence == nil then
    properties.sword_consequence = 1
  end
  if properties.arrow_consequence == nil then
    properties.arrow_consequence = 1
  end
  if properties.movement_create == nil then
    properties.movement_create = function()
      local m = sol.movement.create("random_path")
      return m
    end
  end
  if properties.must_be_aligned_to_attack == nil then
    properties.must_be_aligned_to_attack = true
  end
  if properties.dodge_threshold == nil then
    properties.dodge_threshold = 56
  end
  if properties.dodge_frequency == nil then
    properties.dodge_frequency = 6000
  end
  if properties.max_dodge_distance == nil then
    properties.max_dodge_distance = 120
  end
  if properties.attack_sound == nil then
    properties.attack_sound = "stone"
  end
  if properties.dodge_movement_speed == nil then
    properties.dodge_movement_speed = 250
  end
  if properties.vulnerable_while_dodging == nil then
    properties.vulnerable_while_dodging = true
  end


  function enemy:on_created()

    self:set_life(properties.life)
    self:set_damage(properties.damage)
    self:create_sprite(properties.sprite)
    self:set_hurt_style(properties.hurt_style)
    self:set_pushed_back_when_hurt(properties.pushed_when_hurt)
    self:set_push_hero_on_sword(properties.push_hero_on_sword)
    self:set_obstacle_behavior(properties.obstacle_behavior)
    self:set_size(properties.size_x, properties.size_y)
    self:set_origin(properties.size_x / 2, properties.size_y - 3)
    self:set_attack_consequence("explosion", properties.explosion_consequence)
    self:set_attack_consequence("fire", properties.fire_consequence)
    self:set_attack_consequence("sword", properties.sword_consequence)
    self:set_attack_consequence("arrow", properties.arrow_consequence)



  end

  function enemy:on_movement_changed(movement)

    local direction4 = movement:get_direction4()
    local sprite = self:get_sprite()
    sprite:set_direction(direction4)
  end

	local previous_on_removed = enemy.on_removed
	function enemy:on_removed()

	  if previous_on_removed then
		previous_on_removed(enemy)
	  end

	  for _, child in ipairs(children) do
		child:remove()
	  end
	end


  function enemy:on_obstacle_reached(movement)
    
    if not going_hero and not dodging then
      self:go_random()
      self:check_hero()
    end
  end


  function enemy:check_hero()

    local hero = self:get_map():get_entity("hero")
    local _, _, layer = self:get_position()
    local _, _, hero_layer = hero:get_position()
    local near_hero =
        (layer == hero_layer or enemy:has_layer_independent_collisions()) and
        self:get_distance(hero) < properties.detection_distance
        self:is_in_same_region(hero)

    dist_hero = self:get_distance(hero)

    --set hero_detected to true or false if hero is within properties.detection_distance
    if near_hero then hero_detected = true else hero_detected = false end

    --decide whether to head toward the hero or wander aimlessly
    if near_hero and not going_hero then
      self:go_hero()
    elseif not near_hero and going_hero then
      self:go_random()
    end

    sol.timer.start(self, 100, function() self:check_hero() end)

  end



  function enemy:on_restarted()
    if not dodging then self:get_sprite():set_animation("walking") end
	  local map = self:get_map()
	  local hero = map:get_hero()
    
    self:go_random()
    self:check_hero()
	  can_attack = true
    can_dodge = true

	  sol.timer.start(enemy, 100, function()

			local hero_x, hero_y = hero:get_position()
			local x, y = enemy:get_center_position()
      local aligned


			if can_attack == true then

        --check if hero is aligned, if necessary
        if properties.must_be_aligned_to_attack == true then
          if ((math.abs(hero_x - x) < 16 or math.abs(hero_y - y) < 16))
          and hero_detected == true then
            aligned = true
          end
        else -- if alignment isn't necessary, just check distance
          if hero_detected == true then
            aligned = true
          end 
        end

        --if the hero is aligned, or doesn't need to be, attack
        if aligned == true and dodging == false then
  			  self:attack()
  				can_attack = false
  				sol.timer.start(enemy, properties.attack_frequency, function()
  				  can_attack = true
  				end)
        end

			end --end of if can_attack == true


      if can_dodge == true then
        if dist_hero < properties.dodge_threshold then
          self:dodge()
          can_dodge = false
  				sol.timer.start(enemy, properties.dodge_frequency, function()
  				  can_dodge = true
  				end)
        end --end of within dodge distance check
      end --end of if can_dodge == true


			return true  -- Repeat the timer.

	  end)--end of timer argument

  end--end of on:restarted function


  function enemy:go_random()
    going_hero = false
    local m = properties.movement_create()
    if m == nil then
      -- No movement.
      self:get_sprite():set_animation("stopped")
      m = self:get_movement()
      if m ~= nil then
        -- Stop the previous movement.
        m:stop()
      end
    else
      m:set_speed(properties.normal_speed)
      m:set_ignore_obstacles(properties.ignore_obstacles)
      m:start(self)
    end
  end


  function enemy:go_hero()
    going_hero = true
    local m = sol.movement.create("target")
    m:set_speed(properties.faster_speed)
    m:set_ignore_obstacles(properties.ignore_obstacles)
    m:start(self)
    self:get_sprite():set_animation("walking")
  end

	function enemy:attack()
	  local map = enemy:get_map()
	  local hero = map:get_hero()
	  if not enemy:is_in_same_region(hero) then
		return true  -- Repeat the timer.
	  end

	  local sprite = enemy:get_sprite()
	  local x, y, layer = enemy:get_position()
	  local direction = sprite:get_direction()

	  -- Where to create the projectile.
	  local dxy = {
		{  8,  -4 },
		{  0, -13 },
		{ -8,  -4 },
		{  0,   0 },
	  }

	  sprite:set_animation("shooting")
	  enemy:stop_movement()
	  sol.timer.start(enemy, 200, function()
  		sol.audio.play_sound(properties.attack_sound)
  		local stone = enemy:create_enemy({
  		  breed = properties.projectile_breed,
  		  x = dxy[direction + 1][1],
  		  y = dxy[direction + 1][2],
  		})
  		children[#children + 1] = stone
  		stone:go(direction)
  	  sprite:set_animation("walking")
      self:go_random()
      self:check_hero()

	  end)
	end


  function enemy:dodge()
    can_attack = false
    dodging = true
    self:set_can_attack(false)
    local sprite = enemy:get_sprite()
    if properties.vulnerable_while_dodging == false then self:set_attack_consequence("sword", "ignored") end

      sprite:set_animation("dodging")
      local dodge_direction = math.random(360)
      telm:set_angle(math.rad(dodge_direction))
      telm:set_speed(properties.dodge_movement_speed)
      telm:set_max_distance(properties.max_dodge_distance)
      telm:set_smooth()
      telm:start(self)

      sol.timer.start(enemy, 1000, function() --dodged timer
        local sprite = enemy:get_sprite()
        sprite:set_animation("walking")
        self:set_can_attack(true)
        dodging = false
        can_attack = true
        self:set_default_attack_consequences()
        self:go_random()
        self:check_hero()


      end)--end of dodged timer

  end --end of dodge function



end

return behavior