-- Lua script of map goatshead_island/interiors/CV_dusit.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()

end)

function dusit:on_interaction()
  if not game:get_value("quest_dusit") then
    game:start_dialog("_goatshead.npcs.crabhook.dusit.1", function(answer)
      if answer == 1 then
        game:start_dialog("_goatshead.npcs.crabhook.dusit.2", function()
          game:set_value("quest_dusit", 0)
        end)
      end
    end)

  elseif game:get_value("quest_dusit") == 0 then
    game:start_dialog("_goatshead.npcs.crabhook.dusit.3")

  elseif game:get_value("quest_dusit") == 2 then
    game:start_dialog("_goatshead.npcs.crabhook.dusit.4", function()
      game:set_value("quest_dusit", 3)
    end)

  elseif game:get_value("quest_dusit") == 3 then
    game:start_dialog("_goatshead.npcs.crabhook.dusit.5")
  end
end
