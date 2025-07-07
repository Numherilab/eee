-- Lua script of map oakhaven/caves/abyss.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local particles = {}
local MAX_PARTICLES = 50
local PARTICLE_SPEED = 11

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(5)
  sol.menu.start(map, lighting_effects)

  sol.achievements.unlock("ach_abyss")

  if game:get_value("oakhaven_palace_rune_activated") then
    glowing_rune:set_enabled(true)
    rune_enabler:set_enabled(true)
  end

--particle effect creation
  local i = 1
  sol.timer.start(map, math.random(100,250), function()
    particles[i] = sol.sprite.create("entities/pollution_ash")
    particles[i]:set_xy(math.random(-350, 300), math.random(-800, 200))
    local m = sol.movement.create("random")
    m:set_speed(PARTICLE_SPEED)
--    m:set_ignore_suspend(false)
    m:start(particles[i])
    i = i + 1
    if i > MAX_PARTICLES then i = 0 end
    return true
  end)

end)




--map banner
function map_banner_activator:on_activated()
  map:get_entity("^map_banner_sensor_2"):set_enabled(true)
  map_banner_activator:set_enabled(false)
end

function rune_enabler:on_activated()
  rune_sensor:set_enabled()
end

function rune_sensor:on_activated()
  game:start_dialog("_oakhaven.observations.abyss.draw_in", function()
    hero:teleport("oakhaven/caves/abyss_arena", "from_above")
  end)
  --after beating the boss:
  --game:set_value("quest_abyss", 3)
end


--particle effect draw
function map:on_draw()
    local x, y, layer = glowing_rune:get_position()
    for i=1, #particles do
      map:draw_visual(particles[i], x, y)
    end
end
