local map = ...
local game = map:get_game()
local particles = {}
local MAX_PARTICLES = 50
local PARTICLE_SPEED = 11

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(4)
  sol.menu.start(map, lighting_effects)

  map:set_doors_open"boss_door"

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


function exit_sensor:on_activated()
  exit_teleporter:set_enabled(true)
end

function boss_sensor:on_activated()
  boss_sensor:remove()
  local x,y,z = abyss_beast:get_position()
  map:create_custom_entity{
    x=x,y=y+5,layer=z,width=16,height=16,direction=0,
    model="ephemeral_effect",sprite="enemies/bosses/abyss_beast_teleport_flash"
  }
  abyss_beast:set_enabled(true)
  map:close_doors"boss_door"
end

function abyss_beast:on_dead()
  if game:get_value("quest_abyss") then game:set_value("quest_abyss", 3) end
  map:focus_on(map:get_camera(), boss_door, function()
    map:open_doors"boss_door"
  end)
  game:set_value("defeated_abyss_beast")
  sol.timer.start(game, 2000, function() sol.achievements.unlock("ach_abyss_beast") end)
end
