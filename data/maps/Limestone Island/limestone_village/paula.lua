-- Lua script of map Limestone Island/limestone_village/paula.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function paula:on_interaction()
   if game:get_value("paula_done") == true then
      game:start_dialog("_limestone_island.npcs.paula.done")
   elseif game:has_item("old_stockpot") == true then
    game:start_dialog("_limestone_island.npcs.paula.old_pot", function() map:create_pickable({
      layer = 0,
      x = 160,
      y = 112,
      treasure_name = "elixer",
      
    }) game:set_value("paula_done", true) end)
  elseif game:has_item("stockpot") == true then
    game:start_dialog("_limestone_island.npcs.paula.new_pot", function() map:create_pickable({
      layer = 0,
      x = 160,
      y = 112,
      treasure_name = "elixer",
      
    }) game:set_value("paula_done", true) end)
  else
    game:start_dialog("_limestone_island.npcs.paula.1")
    game:set_value("paula_talked_to", true)
  end
end