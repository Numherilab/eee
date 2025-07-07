local enemy = ...
local map = enemy:get_map()
local particles = {}
local MAX_PARTICLES = 3
local PARTICLE_SPEED = 40

enemy.particle_effects = "pollution"
local behavior = require("enemies/lib/towards_hero")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  size_x = 16,
  life = 1,
  damage = 1,
--  ignore_obstacles = true,
  obstacle_behavior = "flying",
  normal_speed = 75,
  faster_speed = 75,
  detection_distance = 2,
  dying_sprite = "enemies/enemy_killed_projectile",
}

behavior:create(enemy, properties)

enemy:set_layer_independent_collisions(true)

function enemy:go(angle)
  local m = sol.movement.create("straight")
  m:set_speed(100)
  m:set_angle(angle)
  m:set_max_distance(120)
  m:start(enemy)
  function m:on_finished() enemy:restart() end
  function m:on_obstacle_reached() enemy:restart() end
end

enemy:register_event("on_created", function()
--particle effect creation
  local i = 1
  sol.timer.start(map, math.random(100,250), function()
    particles[i] = sol.sprite.create("entities/pollution_ash")
    particles[i]:set_xy(math.random(-20, 20), math.random(-24, 0))
    local m = sol.movement.create("random")
    m:set_speed(PARTICLE_SPEED)
    m:set_ignore_suspend(false)
    m:start(particles[i])
    i = i + 1
    if i > MAX_PARTICLES then i = 0 end
    if enemy:exists() and enemy:is_enabled() then return true end
  end)
end)

--particle effect draw
function enemy:on_post_draw()
    local x, y, layer = enemy:get_position()
    for i=1, #particles do
      map:draw_visual(particles[i], x, y)
    end
end