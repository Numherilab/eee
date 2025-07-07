local behavior = {}




function behavior:create(enemy, properties)

  local dist_hero
  local aware_of_hero = false
  local can_attack = true
  local going_hero = false

  -- Set default properties.
  if properties.life == nil then
    properties.life = 2
  end
  if properties.damage == nil then
    properties.damage = 2
  end
  if properties.normal_speed == nil then
    properties.normal_speed = 20
  end
  if properties.faster_speed == nil then
    properties.faster_speed = 75
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
    properties.detection_distance = 80
  end
  if properties.detection_distance_facing == nil then
    properties.detection_distance_facing = 120
  end
  if properties.detection_distance_away == nil then
    properties.detection_distance_away = 32
  end
  if properties.obstacle_behavior == nil then
    properties.obstacle_behavior = "normal"
  end
  if properties.projectile_breed == nil then
    properties.projectile_breed = "misc/octorok_stone"
  end
  if properties.attack_frequency == nil then
    properties.attack_frequency = 3500
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
  if properties.attack_distance == nil then
    properties.attack_distance = 32
  end
  if properties.wind_up_time == nil then
    properties.wind_up_time = 400
  end
  if properties.attack_sound == nil then
    properties.attack_sound = "stone"
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


  function enemy:on_obstacle_reached(movement)

    if not going_hero then
      self:go_random()
      self:check_hero()
    end
  end

  function enemy:on_restarted()
	  local map = self:get_map()
	  local hero = map:get_hero()
    self:go_random()
    self:check_hero()
	  can_attack = true

  end--end of on:restarted function


  function enemy:check_to_attack()
    local map = self:get_map()
    local hero = map:get_hero()
    local hero_x, hero_y = hero:get_position()
    local enem_x, enem_y = enemy:get_center_position()
    local aligned = false
    dist_hero = enemy:get_distance(hero)

    if properties.must_be_aligned_to_attack == true then
      if (math.abs(hero_x - enem_x) <= 16) or (math.abs(hero_y - enem_y) <= 16) then aligned = true end
    end
    if properties.must_be_aligned_to_attack ~= true then aligned = true end

    if aligned and can_attack and aware_of_hero and dist_hero <= properties.attack_distance then

      self:attack()
      can_attack = false
      sol.timer.start(self, properties.attack_frequency, function() can_attack = true end)
    end
  end


  function enemy:go_random()
    going_hero = false
    aware_of_hero = false
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


  function enemy:check_hero()
    sol.timer.start(self, 100, function() self:check_to_attack() end)
    local hero = self:get_map():get_entity("hero")
    local _, _, layer = self:get_position()
    local _, _, hero_layer = hero:get_position()
    local dir_hero = self:get_direction8_to(hero)
    local enemy_dir = (self:get_sprite():get_direction())*2
    local enemy_dir_plus = enemy_dir + 1
    local enemy_dir_minus = enemy_dir - 1
    local check_dist
    if enemy_dir == dir_hero or enemy_dir_plus == dir_hero or enemy_dir_minus == dir_hero then
      check_dist = properties.detection_distance_facing
    else check_dist = properties.detection_distance_away end

    local near_hero =
        (layer == hero_layer or enemy:has_layer_independent_collisions()) and
        self:get_distance(hero) < check_dist and
        self:is_in_same_region(hero)

    if near_hero and not going_hero then
      aware_of_hero = true
      self:go_hero()
    elseif not near_hero and going_hero then
      aware_of_hero = false
      self:go_random()
    end

-- This line causes problems for some reason I don't yet understand.
--    sol.timer.stop_all(self)
    sol.timer.start(self, 100, function() self:check_hero() end)
  end

  function enemy:go_hero()
    going_hero = true
    aware_of_hero = true
    local m = sol.movement.create("target")
    m:set_speed(properties.faster_speed)
    m:set_ignore_obstacles(properties.ignore_obstacles)
    m:start(self)
    self:get_sprite():set_animation("walking")
  end



	function enemy:attack()
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
      sol.audio.play_sound(properties.attack_sound)
  	  sprite:set_animation("attack")

      function sprite:on_animation_finished()
        sprite:set_animation("walking")
        enemy:set_attack_consequence("sword", properties.sword_consequence)
        enemy:go_random()
        enemy:check_hero()
      end

	  end) --end of wind up timer

	end --end of attack function

end

return behavior