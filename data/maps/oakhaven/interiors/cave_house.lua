-- Lua script of map oakhaven/interiors/cave_house.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(4)
  sol.menu.start(map, lighting_effects)

  if game:get_value("oakhaven_lakehouse_secret_switch_pulled") then
    local m=sol.movement.create"straight"
    m:set_max_distance(24)
    m:set_angle(0)
    m:set_speed(200)
    m:start(bed1)
    local m2=sol.movement.create"straight"
    m2:set_max_distance(24)
    m2:set_speed(200)
    m2:set_angle(0)
    m2:start(bed2)
  end
end)

function secret_switch:on_interaction()
  if not game:get_value("oakhaven_lakehouse_secret_switch_pulled") then
    game:start_dialog("_oakhaven.observations.misc.lakehouse_switch1", function(answer)
      if answer == 3 then

          sol.audio.play_sound"switch_3"
          sol.audio.play_sound"switch"
          local m=sol.movement.create"straight"
          m:set_max_distance(24)
          m:set_angle(0)
          m:start(bed1)
          local m2=sol.movement.create"straight"
          m2:set_max_distance(24)
          m2:set_angle(0)
          m2:start(bed2)
          sol.audio.play_sound"hero_pushes"
          game:set_value("oakhaven_lakehouse_secret_switch_pulled", true)

      elseif answer == 4 then
        game:start_dialog("_oakhaven.observations.misc.lakehouse_switch2")
      end
    end)
  else
    sol.audio.play_sound"switch"
  end
end