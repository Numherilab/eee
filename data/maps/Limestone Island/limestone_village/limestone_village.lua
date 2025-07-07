-- Lua script of map Limestone Island/Limestone Village/limestone_village.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  to_goatshead:set_enabled(false)


--jorge walking movement
  local walker_movement = sol.movement.create("path")
  walker_movement:set_path{6, 6, 6, 6, 6, 6, 6, 6, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 6, 6, 6, 6, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2}
  walker_movement:set_speed(30)
  walker_movement:set_loop(true)
  walker_movement:set_ignore_obstacles(true)
  walker_movement:start(walker)

end


-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end


function stair_sensor:on_activated()
local x, y, layer = hero:get_position()
hero:set_position(x, y, layer + 1)
end


-- NPC dialogs

--Tim
function tim:on_interaction()
  if game:get_value("castone_grove_clear") == true then
  
  else
    game:start_dialog("_limestone_island.npcs.tim.1")
  end
end

--Juglan
function juglan:on_interaction()
  -- first time leaving
  if game:get_value("left_limestone") == nil then
    game:start_dialog("_limestone_island.npcs.juglan.first_time_leaving", function(answer)
      if answer == 2 then
        game:start_dialog("_limestone_island.npcs.juglan.trip_confirm", function()
          to_goatshead:set_enabled(true)
        end)
      end
    end)
  -- have left Limestone before
  else
    
  end
end

--Walker
function walker:on_interaction()
  game:start_dialog("_limestone_island.npcs.walker.1")
end