local behavior = {}

-- The properties parameter is a table.
-- All its values are optional except the sprite.
--This is for an enemy like a deku scrub, one that is invulnerable and perhaps hidden
--unless the hero is close, but not too close. It hides unless the hero is between the
--properties min_range and max_range. When the hero is in this area though, the enemy
--will shoot projectiles at the hero. Use the property must_be_aligned_to_shoot to define
--if the enemy shoots in 360 degrees at the hero or just orthogonally. The projectile_breed
--property ought to be a projectile that compliments this. 

--The sprite must have the animations "asleep" "awake" and "shooting". "waking_up" is an
--optional animation that ought to be less than 200ms. The enemy can define the property 
--"awakening_sound" for a sound effect to be played whenever the enemy wakes up.

--This enemy is vulnerable to swords and arrows when it is awake (the hero is in range), but
--it is always vulnerable to explosions and fire.

function behavior:create(enemy, properties)

local children = {}
local can_shoot = true
local awake = false
local dist_hero

  -- Set default properties.
  if properties.life == nil then
    properties.life = 2
  end
  if properties.damage == nil then
    properties.damage = 0
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
    properties.pushed_when_hurt = false
  end
  if properties.push_hero_on_sword == nil then
    properties.push_hero_on_sword = false
  end
  if properties.ignore_obstacles == nil then
    properties.ignore_obstacles = false
  end
  if properties.detection_distance == nil then
    properties.detection_distance = 80
  end
  if properties.obstacle_behavior == nil then
    properties.obstacle_behavior = "normal"
  end
  if properties.projectile_breed == nil then
    properties.projectile_breed = "misc/octorok_stone"
  end
  if properties.shooting_frequency == nil then
    properties.shooting_frequency = 1500
  end
  if properties.sword_consequence == nil then
    properties.sword_consequence = 1
  end
  if properties.arrow_consequence == nil then
    properties.arrow_consequence = 1
  end
  if properties.explosion_consequence == nil then
    properties.explosion_consequence = 1
  end
  if properties.fire_consequence == nil then
    properties.fire_consequence = 1
  end
  if properties.movement_create == nil then
    properties.movement_create = function()
      local m = sol.movement.create("random_path")
      return m
    end
  end
  if properties.asleep_animation == nil then
    properties.asleep_animation = "asleep"
  end
  if properties.awake_animation == nil then
    properties.awake_animation = "awake"
  end
  if properties.must_be_aligned_to_shoot == nil then
    properties.must_be_aligned_to_shoot = true
  end
  if properties.max_range == nil then
    properties.max_range = 100
  end
  if properties.min_range == nil then
    properties.min_range = 45
  end
  if properties.must_be_aligned_to_shoot == nil then
    properties.must_be_aligned_to_shoot = true
  end


  function enemy:on_created()

    self:set_life(properties.life)
    self:set_damage(properties.damage)
    self:set_hurt_style(properties.hurt_style)
    self:set_pushed_back_when_hurt(properties.pushed_when_hurt)
    self:set_push_hero_on_sword(properties.push_hero_on_sword)
    self:set_obstacle_behavior(properties.obstacle_behavior)
    self:set_size(properties.size_x, properties.size_y)
    self:set_origin(properties.size_x / 2, properties.size_y - 3)
    self:set_attack_consequence("explosion", properties.explosion_consequence)
    self:set_attack_consequence("fire", properties.fire_consequence)
    self:set_attack_consequence("sword", "protected")
    self:set_attack_consequence("arrow", "protected")
--    self:set_traversable(false)

    local sprite = self:create_sprite(properties.sprite)
    function sprite:on_animation_finished(animation)
      -- If the awakening transition is finished, make the enemy go toward the hero.
      if animation == properties.awaking_animation then
        enemy:finish_waking_up()
      end
    end
    sprite:set_animation(properties.asleep_animation)

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


  function enemy:on_restarted()
    can_shoot = true
    if awake == true then self:get_sprite():set_animation("awake") else self:get_sprite():set_animation("asleep") end
	  local map = self:get_map()
	  local hero = map:get_hero()
    dist_hero = enemy:get_distance(hero)
    self:check_hero()

    --check if enemy needs to wake up or go to sleep based on if hero is near. Repeat every 80ms
	  sol.timer.start(enemy, 80, function()
      dist_hero = enemy:get_distance(hero)
      if dist_hero < properties.max_range and dist_hero > properties.min_range and awake == false then
        self:wake_up()
      end
      if dist_hero > properties.max_range or dist_hero < properties.min_range then
        if awake == true then self:go_to_sleep() end
      end

      return true
    end)
  end--end of on:restarted function



  function enemy:check_hero()
	  local map = self:get_map()
	  local hero = map:get_hero()
    local direction4 = self:get_direction4_to(hero)
    local sprite = self:get_sprite()
    sprite:set_direction(direction4)
    dist_hero = enemy:get_distance(hero)
    local _, _, layer = self:get_position()
    local hero_x, hero_y, hero_layer = hero:get_position()
    local x, y = enemy:get_center_position()
    local aligned

    if awake == true then
      --see about shooting
      if properties.must_be_aligned_to_shoot == true then
        if ((math.abs(hero_x - x) < 16 or math.abs(hero_y - y) < 16))
        and layer == hero_layer
        then
          aligned = true
        end
      else
        if layer == hero_layer then aligned = true end
      end

      if aligned == true and can_shoot == true then
        self:shoot()
        can_shoot = false
        sol.timer.start(enemy, properties.shooting_frequency, function() can_shoot = true end)
      end

    end --end if awake=true condition


    sol.timer.start(self, 100, function() self:check_hero() end)
  end --end of check hero function


  function enemy:wake_up()
    self:stop_movement()
    if properties.waking_animation ~= nil then
      local sprite = self:get_sprite()
      sprite:set_animation(properties.waking_animation)
    end
    sol.timer.start(self, 200, function() self:finish_waking_up() end)
  end

  function enemy:finish_waking_up()
    self:get_sprite():set_animation(properties.awake_animation)
    awake = true
    if properties.awakening_sound ~= nil then
      sol.audio.play_sound(properties.awakening_sound)      
    end
    self:set_attack_consequence("sword", properties.sword_consequence)
    self:set_attack_consequence("arrow", properties.arrow_consequence)
  end


  function enemy:go_to_sleep()
    self:stop_movement()
    sol.timer.start(self, 200, function() self:finish_going_to_sleep() end)
  end

  function enemy:finish_going_to_sleep()
    self:get_sprite():set_animation(properties.asleep_animation)
    awake = false
    if properties.awakening_sound ~= nil then
      sol.audio.play_sound(properties.awakening_sound)      
    end
    self:set_attack_consequence("sword", "protected")
    self:set_attack_consequence("arrow", "protected")
  end



	function enemy:shoot()
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
	  sol.timer.start(enemy, 300, function()
  		sol.audio.play_sound("stone")
  		local stone = enemy:create_enemy({
  		  breed = properties.projectile_breed,
  		  x = dxy[direction + 1][1],
  		  y = dxy[direction + 1][2],
  		})
  		children[#children + 1] = stone
  		stone:go(direction)
  	  sprite:set_animation(properties.awake_animation)
      self:check_hero()
	  end)
	end

end

return behavior