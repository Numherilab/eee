-- Lua script of map Limestone Island/limestone_village/wally.
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

function wally:on_interaction()
  local wally_value = game:get_value("talked_to_wally")
  if wally_value == nil then
    game:start_dialog("_limestone_island.npcs.wally.1")
    game:set_value("talked_to_wally", 1)
  elseif wally_value == 1 then
    game:start_dialog("_limestone_island.npcs.wally.2")
  elseif wally_value == 2 then
    game:start_dialog("_limestone_island.npcs.wally.3", function() game:add_money(35) end)
    game:set_value("talked_to_wally", 3)
    
  elseif wally_value ==3 then
    game:start_dialog("_limestone_island.npcs.wally.4")
  end
end