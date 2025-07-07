local behavior = {}

--This enemy is like Zelda's Leever. It moves randomly, and periodically will burrow below ground to later pop up. It is invulnerable when below ground. Special properties of this enemy type are time_underground, time_aboveground, and burrow_deviation. Time below/above ground are minimums, with the deviation being the random amount (in ms) to add to that. That keeps them from popping in and out in swarms if you have multiple. You could also use this for a ghost that phases in/out.
--Required sprites are walking, burrowing, and underground (which has to be empty)

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

  local going_hero = false
  local map = enemy:get_map()
  local hero = map:get_hero()
  

  -- Set default properties.
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
    properties.normal_speed = 32
  end
  if properties.faster_speed == nil then
    properties.faster_speed = 48
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
  if properties.obstacle_behavior == nil then
    properties.obstacle_behavior = "normal"
  end
  if properties.movement_create == nil then
    properties.movement_create = function()
      local m = sol.movement.create("random_path")
      return m
    end
  end
  if properties.time_underground == nil then
    properties.time_underground = 1000
  end
  if properties.time_aboveground == nil then
    properties.time_aboveground = 2000
  end
  if properties.burrow_deviation == nil then
    properties.burrow_deviation = 7000
  end
  if properties.burrow_sound == nil then
    properties.burrow_sound = "burrow1"
  end
  

--create enemy properties
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
    --start burrowing behavior

  end


  function enemy:on_movement_changed(movement)

    local direction4 = movement:get_direction4()
    local sprite = self:get_sprite()
    sprite:set_direction(direction4)
  end


  function enemy:on_obstacle_reached(movement)
      self:go_random()
  end

  function enemy:on_restarted()
    self:go_random()
    sol.timer.stop_all(self)
    sol.timer.start(self, (properties.time_aboveground + math.random(properties.burrow_deviation)), function() self:burrow_down() end)
    
  end


  function enemy:go_random()
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

  function enemy:burrow_down()
    self:get_sprite():set_animation("burrowing")
    if enemy:is_on_screen() then sol.audio.play_sound(properties.burrow_sound) end
    sol.timer.start(self, 800, function() self:go_underground() end)
    enemy:create_dust()
  end

  function enemy:burrow_up()
    self:get_sprite():set_animation("burrowing")
    if enemy:is_on_screen() then sol.audio.play_sound(properties.burrow_sound) end
    sol.timer.start(self, 800, function() self:go_aboveground() end)
    enemy:create_dust()
  end

  function enemy:create_dust()
    local i = 1
    sol.timer.start(enemy, 100, function()
      local x,y,z = enemy:get_position()
      local dust = map:create_custom_entity{x=x+math.random(-4,4),y=y+2,layer=z,width=16,height=16,direction=0,
        sprite="entities/dust_cloud_roll"}
      dust:set_drawn_in_y_order(true)
      local m = sol.movement.create"random"
      m:start(dust)
      sol.timer.start(map,2000,function() dust:remove() end)
      i = i+1
      return i <= 11
    end)
  end

  function enemy:go_underground()
    self:get_sprite():set_animation("underground")
    self:set_can_attack(false)
    sol.timer.start(self, (properties.time_underground + math.random(properties.burrow_deviation)), function() self:burrow_up() end)
    
  end

  function enemy:go_aboveground()
    self:set_can_attack(true)
    self:get_sprite():set_animation("walking")
    if properties.aboveground_callback then properties.aboveground_callback() end
    self:restart()
  end



end

return behavior