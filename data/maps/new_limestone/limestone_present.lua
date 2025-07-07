-- Lua script of map new_limestone/limestone_present.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  game:set_world_fall_mode(map:get_world(), "fall")

  if game:get_value("left_limestone") then
    juglan:remove()
  end 
  if not game:get_value("goatshead_opening") then juglan_2:remove() end
end)

--This juglan is only for your first ride out:
function juglan:on_interaction()
  -- first time leaving
  if game:get_value("left_limestone") == nil then
    game:start_dialog("_new_limestone_island.npcs.juglan.first_time_leaving", function(answer)
      if answer == 2 then
        game:start_dialog("_new_limestone_island.npcs.juglan.first_time_leaving_confirm", function()
          hero:teleport("goatshead_island/goatshead_harbor", "from_limestone")
          game:set_value("left_limestone", true)

        end)
      end
    end)
  -- have left Limestone before
  else
    game:start_dialog("_new_limestone_island.npcs.juglan.travel_to_goatshead", function(answer)
      if answer == 2 then
        to_goatshead:set_enabled(true)
      end
      end)
  end
end

--This Juglan comes back and is there for the rest of the game
function juglan_2:on_interaction()
  game:start_dialog"_new_limestone_island.npcs.juglan_2.1"
end
