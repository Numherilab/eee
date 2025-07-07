-- Lua script of map goatshead_island/interiors/CV_arni.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()


function arni:on_interaction()
  if game:get_value("talked_to_arni") ~= true then
    if game:get_value("looking_for_crabhook_monster") == nil then
      game:start_dialog("_goatshead.npcs.crabhook.arni.1")
    else
      game:start_dialog("_goatshead.npcs.crabhook.arni.2", function()
        game:set_value("talked_to_arni", true)
        game:set_value("quest_crabhook_shoal_monster", 2) --quest log
      end)
    end
  else
    game:start_dialog("_goatshead.npcs.crabhook.arni.3")
  end
end
