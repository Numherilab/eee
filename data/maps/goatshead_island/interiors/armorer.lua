-- Lua script of map goatshead_island/interiors/armorer.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local shop = require("scripts/shops/blacksmith")


function plumbum:on_interaction()
  if game:get_value("plumb_improved_armor") ~= true then
    game:start_dialog("_goatshead.npcs.plumbum.1", function (answer)
      if answer == 3 and game:get_money() >49 then
        game:start_dialog("_goatshead.npcs.plumbum.2")
        game:set_value("defense", game:get_value("defense") + 1)
        game:remove_money(50)
        game:set_value("plumb_improved_armor", true)
      elseif answer == 3 and game:get_money() <50 then
        game:start_dialog("_game.insufficient_funds")
      end
    end)

  else
    game:start_dialog("_goatshead.npcs.plumbum.3")
  
  end
end

function palladio:on_interaction()
  shop:open_shop(game)
end --palladio interaction end