-- Lua script of map Limestone Island/limestone_village/shifty_ulrich.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  if game:get_value("sad_ulrich") == true then
    old_stockpot:set_enabled(false)
  end
  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function ulrich:on_interaction()
  if game:get_value("sad_ulrich") == true then
    game:start_dialog("_limestone_island.npcs.ulrich.sad_ulrich")
  elseif game:get_value("happy_ulrich") == true then
    game:start_dialog("_limestone_island.npcs.ulrich.happy_ulrich")
  elseif game:get_value("paula_talked_to") ~= true then
    game:start_dialog("_limestone_island.npcs.ulrich.1")
  else
    game:start_dialog("_limestone_island.npcs.ulrich.caught", function(answer) 
      if answer == 2 then
        game:start_dialog("_limestone_island.npcs.ulrich.take_pot", function() 
          old_stockpot:set_enabled(false)
          map:create_pickable({
            layer = 0,
            x = 176,
            y = 112,
            treasure_name = "old_stockpot", })
        end)
        game:set_value("sad_ulrich", true)
      elseif answer == 3 then
        game:start_dialog("_limestone_island.npcs.ulrich.keep_pot", function() 
          map:create_pickable({
            layer = 0,
            x = 176,
            y = 112,
            treasure_name = "rupee",
            treasure_variant = 4,})
        end)
        game:set_value("happy_ulrich", true)
      end
    end)
end
end