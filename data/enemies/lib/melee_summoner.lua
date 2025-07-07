local behavior = {}




function behavior:create(enemy, properties)

  local dist_hero
  local can_melee = true
  local can_ranged
  local going_hero = false
  local summon_index

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
    properties.detection_distance = 90
  end
  if properties.obstacle_behavior == nil then
    properties.obstacle_behavior = "normal"
  end
  if properties.projectile_breed == nil then
    properties.projectile_breed = "misc/root_small"
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
    properties.must_be_aligned_to_attack = false
  end
  if properties.melee_distance == nil then
    properties.melee_distance = 32
  end
  if properties.ranged_distance == nil then
    properties.ranged_distance = 75
  end
  if properties.melee_cooldown == nil then
    properties.melee_cooldown = 3500
  end
  if properties.ranged_cooldown == nil then
    properties.ranged_cooldown = 5000
  end
  if properties.wind_up_time == nil then
    properties.wind_up_time = 400
  end
  if properties.melee_sound == nil then
    properties.melee_sound = "sword3"
  end
  if properties.max_summons == nil then
    properties.max_summons = 3
  end
  if properties.summon_frequency == nil then
    properties.summon_frequency = 1500
  end
  if properties.protected_while_summoning == nil then
    properties.protected_while_summoning = false
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
    can_melee = true
  end

  function enemy:on_movement_changed(movement)

    local direction4 = movement:get_direction4()
    local sprite = self:get_sprite()
    sprite:set_direction(direction4)
  end


  function enemy:on_obstacle_reached(movement)

    if not going_hero then
      self:go_random()
      self:check_hero()
    end
  end

  function enemy:on_restarted()
    enemy:set_attack_consequence("sword", properties.sword_consequence)
    enemy:set_attack_consequence("arrow", properties.sword_consequence)
    self:go_random()
    self:check_hero()
    can_melee = true
    sol.timer.start(properties.ranged_cooldown/2, function() can_ranged = true end)
  end



  function enemy:check_hero()

    local hero = self:get_map():get_entity("hero")
    local _, _, layer = self:get_position()
    local _, _, hero_layer = hero:get_position()
    local near_hero =
        (layer == hero_layer or enemy:has_layer_independent_collisions()) and
        self:get_distance(hero) < properties.detection_distance and
        self:is_in_same_region(hero)
    dist_hero = self:get_distance(hero)

    if near_hero and not going_hero then
      self:go_hero()
    elseif near_hero and going_hero then
      self:check_to_attack()
    elseif not near_hero and going_hero then
      self:go_random()
    end

-- This line causes problems for some reason I don't yet understand.
--    sol.timer.stop_all(self)
    sol.timer.start(self, 100, function() self:check_hero() end)
  end



  function enemy:check_to_attack()
    local map = self:get_map()
    local hero = map:get_hero()
    dist_hero = enemy:get_distance(hero)
		local hero_x, hero_y = hero:get_position()
		local x, y = enemy:get_center_position()
    local aligned

     --check if the enemy will melee
		if can_melee == true and dist_hero <= properties.melee_distance then
      --check if hero is aligned, if necessary
      if properties.must_be_aligned_to_attack == true then
        if ((math.abs(hero_x - x) < 16 or math.abs(hero_y - y) < 16)) then aligned = true else aligned = false end
      else aligned = true
      end
      --if the hero is aligned, or doesn't need to be, attack
      if aligned == true then
  	    self:melee_attack()
  		  can_melee = false
  		  sol.timer.start(enemy, properties.melee_cooldown, function()
  				can_melee = true
  			end)
       end
    end

    --check if the evenmy will use ranged attack (alignment for summoning makes no sense)
		if can_ranged == true and dist_hero > properties.melee_distance and dist_hero <= properties.ranged_distance then
      summon_index = 1
      self:ranged_attack()
      can_ranged = false
      --set timer to map instead of enemy to prevent summoning every time enemy is hit
  		sol.timer.start(map, properties.ranged_cooldown, function()
  			can_ranged = true
  		end)
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
      self:get_sprite():set_animation("walking")
    end
  end


	function enemy:melee_attack()
--this timer is here redundantly for testing
  		  sol.timer.start(enemy, properties.melee_cooldown, function()
  				can_melee = true
  			end)
    --first, check if the hero is in the same region
	  local map = enemy:get_map()
	  local hero = map:get_hero()
	  if not enemy:is_in_same_region(hero) then
  		return true  -- Repeat the timer.
	  end

	  local sprite = enemy:get_sprite()
	  local x, y, layer = enemy:get_position()
	  local direction = sprite:get_direction()

	  sprite:set_animation("wind_up")
    enemy:set_attack_consequence("sword", "protected")
	  enemy:stop_movement()
    --charging phase
	  sol.timer.start(enemy, properties.wind_up_time, function()
      sol.audio.play_sound(properties.melee_sound)
  	  sprite:set_animation("attack")

      function sprite:on_animation_finished()
        sprite:set_animation("walking")
        enemy:set_attack_consequence("sword", properties.sword_consequence)
        enemy:go_random()
        enemy:check_hero()
      end

	  end) --end of wind up timer
	end --end of attack function


  function enemy:ranged_attack()
--this timer is here redundantly for testing
  		sol.timer.start(enemy, properties.ranged_cooldown, function()
  			can_ranged = true
  		end)
    local map = enemy:get_map()
    local hero = map:get_hero()
    local sprite = enemy:get_sprite()
    sprite:set_animation("summoning")
    enemy:stop_movement()
    if properties.protected_while_summoning == true then
      enemy:set_attack_consequence("sword", "protected") enemy:set_attack_consequence("arrow", "protected")
    end

    sol.timer.start(properties.summon_frequency, function()
      if properties.summon_sound ~= nil then sol.audio.play_sound(properties.summon_sound) end
      local herox, heroy, herol = hero:get_position()
      map:create_enemy({
        name = vine_enemy, layer = herol, x = herox, y = heroy, direction = 0, breed = properties.projectile_breed, 
      })
      summon_index = summon_index + 1
      if summon_index < properties.max_summons then return true end
    end)

    function sprite:on_animation_finished()
        sprite:set_animation("walking")
        enemy:set_attack_consequence("sword", properties.sword_consequence)
        enemy:set_attack_consequence("arrow", properties.sword_consequence)
        enemy:go_random()
        enemy:check_hero()
    end

  end


end

return behavior