-- Lua script of map snapmast_reef/landing.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  require("scripts/fx/sound_atmosphere_manager"):start_atmosphere(map, "rain")
  local world = map:get_world()
  game:set_world_rain_mode(world, "storm")
  if game:get_value("quest_snapmast") == 0 then game:set_value("quest_snapmast", 1) end

  local rain_manager = require("scripts/weather/rain_manager")
  rain_manager:set_storm_speed(180)
  rain_manager:set_lightning_delay(6000, 18000)
  rain_manager:set_darkness(60, 120)

end)


--[[
function morus:on_interaction()
  if game:has_item("oceansheart_chart") == true then
    if not game:get_value("showed_morus_the_oceansheart_chart") then
      game:start_dialog("_oakhaven.npcs.morus.8_have_ocean_chart", function()
        game:start_dialog("_oakhaven.npcs.morus.ferry_2", function(answer)
          if answer == 1 then
            hero:teleport("oakhaven/port", "morus_landing")
          elseif answer == 2 then
            game:start_dialog("_oakhaven.npcs.morus.ferry_already")
          elseif answer == 3 then
            hero:teleport("isle_of_storms/isle_of_storms_landing", "ferry_landing")
          end
        end)
      end)
      game:set_value("showed_morus_the_oceansheart_chart", true)

    else
      game:start_dialog("_oakhaven.npcs.morus.ferry_2", function(answer)
        if answer == 1 then
          hero:teleport("oakhaven/port", "morus_landing")
        elseif answer == 2 then
          game:start_dialog("_oakhaven.npcs.morus.ferry_already")
        elseif answer == 3 then
          hero:teleport("isle_of_storms/isle_of_storms_landing", "ferry_landing")
        end
      end)
    end
  else
    game:start_dialog("_oakhaven.npcs.morus.ferry_1_reef", function(answer)
      if answer == 2 then
        hero:teleport("oakhaven/port", "morus_landing")
      end
    end)
  end
end
--]]