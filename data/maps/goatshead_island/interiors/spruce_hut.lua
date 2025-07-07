-- Lua script of map goatshead_island/interiors/spruce_hut.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  if game:get_value("talked_to_ilex_1") == true then ilex:set_enabled(false) end

end)


function ilex:on_interaction()
  if game:get_value("talked_to_ilex_1") ~= true then
    if game:get_value("have_spruce_clue") == true then
      game:start_dialog("_goatshead.npcs.ilex.1", function()
        game:set_value("talked_to_ilex_1", true)
        game:set_value("spruce_head_shirine_num_fountains_activated", 0) --quest log
        game:set_value("quest_spruce_head", 1) --quest log
      end)
    else
      game:start_dialog("_goatshead.npcs.ilex.0")
    end
  else
    game:start_dialog("_goatshead.npcs.ilex.2")
  end

end
