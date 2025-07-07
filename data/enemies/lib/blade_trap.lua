local behavior = {}

--This enemy will stay in one spot unless the hero passes along the same X or Y as the enemy, within the waking distance
--Then it will zoom toward the hero's spot. Upon hitting the hero or something else, the enemy returns to its spot.

-- Example of use from an enemy script:

-- local enemy = ...
-- local behavior = require("enemies/lib/waiting_for_hero")
-- local properties = {
--   sprite = "enemies/globul",
--   life = 4,
--   damage = 2,
--   normal_speed = 32,
--   faster_speed = 48,
--   hurt_style = "normal",
--   push_hero_on_sword = false,
--   pushed_when_hurt = true,
--   asleep_animation = "stopped",
--   awaking_animation = "awaking",
--   normal_animation = "walking",
--   ignore_obstacles = false,
--   obstacle_behavior = "flying",
--   awakening_sound  = "stone",
--   waking_distance = 100,
-- }
-- behavior:create(enemy, properties)

-- The properties parameter is a table.
-- All its values are optional except the sprite.

function behavior:create(enemy, properties)

  local going_hero = false
  local awaken = false
  local spot_x
  local spot_y
  local rest_m = sol.movement.create("target")

  -- Set default values.
  if properties.size_x == nil then
    properties.size_x = 16
  end
  if properties.size_y == nil then
    properties.size_y = 16
  end
  if properties.life == nil then
    properties.life = 2
  end
  if properties.damage == nil then
    properties.damage = 2
  end
  if properties.normal_speed == nil then
    properties.normal_speed = 35
  end
  if properties.faster_speed == nil then
    properties.faster_speed = 175
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
  if properties.asleep_animation == nil then
    properties.asleep_animation = "stopped"
  end
  if properties.normal_animation == nil then
    properties.normal_animation = "walking"
  end
  if properties.ignore_obstacles == nil then
    properties.ignore_obstacles = false
  end
  if properties.obstacle_behavior == nil then
    properties.obstacle_behavior = "normal"
  end
  if properties.waking_distance == nil then
    properties.waking_distance = 200
  end
  if properties.invincible == nil then
    properties.invincible = true
  end
  if properties.waking_sound == nil then
    properties.waking_sound = "bow"
  end

  function enemy:on_created()

    self:set_life(properties.life)
    self:set_damage(properties.damage)
    self:set_hurt_style(properties.hurt_style)
    self:set_pushed_back_when_hurt(properties.pushed_when_hurt)
    self:set_push_hero_on_sword(properties.push_hero_on_sword)
    self:set_size(properties.size_x, properties.size_y)
    self:set_origin(properties.size_x / 2, properties.size_y - 3)
    self:set_obstacle_behavior(properties.obstacle_behavior)
    if properties.invincible == true then self:set_invincible(true) end

    local sprite = self:create_sprite(properties.sprite)
    sprite:set_animation(properties.asleep_animation)
    self:set_spot()

  end

  function enemy:on_movement_changed(movement)

    local direction4 = movement:get_direction4()
    local sprite = self:get_sprite()
    sprite:set_direction(direction4)
  end

  function enemy:on_obstacle_reached(movement)
    self:return_to_spot()
  end

  function enemy:on_restarted()
    self:return_to_spot()
    self:check_hero()
  end


  function enemy:set_spot()
    spot_x, spot_y, _ = self:get_position()
  end


  --goes back to resting place
  function enemy:return_to_spot()  
    local trap_x, trap_y, _ = self:get_position()
    if trap_x == spot_x and trap_y == spot_y then
      going_hero = false  
    else
      rest_m:set_target(spot_x, spot_y)
      rest_m:set_speed(properties.normal_speed)
      rest_m:set_ignore_obstacles(properties.ignore_obstacles)
      rest_m:start(self)  
    end
  end


  function rest_m:on_finished()
    going_hero = false
  end



  function enemy:check_hero()

    local hero = self:get_map():get_entity("hero")
    local hero_x, hero_y, hero_layer = hero:get_position()
    local trap_x, trap_y, trap_layer = self:get_position()
    local near_hero = self:get_distance(hero) < properties.waking_distance and self:is_in_same_region(hero)
    
    if ((math.abs(hero_x - trap_x) < 16 or math.abs(hero_y - trap_y) < 16)) and near_hero then
      sol.timer.stop_all(self)
      if going_hero == false then enemy:go_hero() end
    end

    sol.timer.stop_all(self)
    sol.timer.start(self, 100, function() self:check_hero() end)
  end





  function enemy:go_hero()
    sol.timer.stop_all(self)
    local m = sol.movement.create("straight")
    local hero = self:get_map():get_entity("hero")
    local angle = self:get_direction4_to(hero)
    if angle == 1 then angle = (math.pi/2) end
    if angle == 2 then angle = math.pi end
    if angle == 3 then angle = (3 * math.pi / 2) end
    m:set_angle(angle)
    m:set_speed(properties.faster_speed)
    m:set_ignore_obstacles(properties.ignore_obstacles)
    m:start(self)
    going_hero = true
  end






end

return behavior