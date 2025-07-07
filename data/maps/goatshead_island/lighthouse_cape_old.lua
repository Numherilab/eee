-- Lua script of map Goatshead Island/lighthouse_cape.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  if game:get_value("goatshead_lighthouse_activated") == true then
    house_light_1:set_enabled(true)
    house_light_2:set_enabled(true)
    house_light_3:set_enabled(true)
    house_light_4:set_enabled(true)
  end
  -- You can initialize the movement and sprites of various
  -- map entities here.
end

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
end