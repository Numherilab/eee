local behavior = {}

-- Behavior of an enemy that is in a sleep state,
-- goes towards the the hero when he sees him,
-- and then goes randomly if it loses sight.
-- The enemy has only two new sprites animation: an asleep one,
-- and an awaking transition.
-- a different walking one can be set in the properties, though.

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

  local flying_away = false
  local awaken = false

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
    properties.waking_distance = 100
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

    local sprite = self:create_sprite(properties.sprite)

    sprite:set_animation(properties.asleep_animation or "stopped")
  end


  function enemy:on_restarted()
    local map = enemy:get_map()
    local hero = map:get_hero()
    local sprite = enemy:get_sprite()
    sprite:set_animation"stopped"

    sol.timer.start(enemy, 0, function()
      local near_hero = enemy:is_in_same_region(hero)
      and enemy:get_distance(hero) <= properties.waking_distance

      if near_hero then
        enemy:fly_away()
      else
        return 50
      end
    end)

    sol.timer.start(enemy, math.random(1000, 6000), function()
      if not flying_away then
       sprite:set_direction((sprite:get_direction() + 2) % 4)
        return true
      end
    end)
  end


  function enemy:fly_away()
    sol.timer.stop_all(enemy)
    flying_away = true
    local map = enemy:get_map()
    local hero = map:get_hero()
    local sprite = enemy:get_sprite()
    sprite:set_animation"walking"
    sol.audio.play_sound"bird_flying_away"
    local angle = hero:get_angle(enemy)
    if angle > math.pi /2 and angle < 3 * math.pi / 2 then --hero is right of bird
      sprite:set_direction(2)
      angle = 2.5
    else --hero is left of bird
      sprite:set_direction(0)
      angle = .5
    end
    local m = sol.movement.create("straight")
    m:set_angle(angle)
    m:set_speed(200)
    m:set_ignore_obstacles()
    m:set_max_distance(400)
    enemy:set_layer(map:get_max_layer())
    m:start(enemy, function() enemy:remove() end)
  end

end

return behavior