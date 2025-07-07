-- Lua script of map goatshead_island/riverbank.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  if (game:get_value("quest_test13") or 0) >= 1 then
    two_eye_rock_shroom:remove()
  end
end)


function carrots:on_interaction()
  if game:get_value("carrot_counter") == nil then
    game:start_dialog("_goatshead.observations.carrots.1", function(answer)
      if answer == 2 then
        game:add_life(2)
        game:set_value("carrot_counter", 1)
      end
    end)
  elseif game:get_value("carrot_counter") == 1 then
    game:start_dialog("_goatshead.observations.carrots.1", function(answer)
      if answer == 2 then
        game:add_life(2)
        game:set_value("carrot_counter", 2)
      end
    end)
  elseif game:get_value("carrot_counter") == 2 then
    game:start_dialog("_goatshead.observations.carrots.2")

  end
end

function two_eye_rock_shroom:on_dead()
  if game:get_value("quest_test13") == 0 then
    game:set_value("quest_test13", 1)
  end
  game:set_value("goatshead_island_two_eye_rock_shroom_dead", true)
end

function gerald:on_interaction()
  if game:get_value("west_goat_cracked_block_2") ~= nil then
    game:start_dialog("_goatshead.npcs.overworld.bomb_rocks_guy_2")
  else
    game:start_dialog("_goatshead.npcs.overworld.bomb_rocks_guy_1")
  end
end
