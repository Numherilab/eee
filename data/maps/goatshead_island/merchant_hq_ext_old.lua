-- Lua script of map goatshead_island/merchant_hq_ext.
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


function guard_3:on_interaction()
  if game:get_value("barbell_brutes_defeated") ~= true then
    game:start_dialog("_goatshead.npcs.guards.7")
  else
    game:start_dialog("_goatshead.npcs.guards.post_defeat.1")
  end
end

function guard_4:on_interaction()
  if game:get_value("barbell_brutes_defeated") ~= true then
    game:start_dialog("_goatshead.npcs.guards.6")
  else
    game:start_dialog("_goatshead.npcs.guards.post_defeat.1")
  end
end