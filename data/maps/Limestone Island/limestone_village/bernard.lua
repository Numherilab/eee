-- Lua script of map Limestone Island/limestone_village/bernard.
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

function bernard:on_interaction()
  if game:get_value("sometimes_spider_dead") == true and game:get_value("sometimes_spider_reward") == true then
    game:start_dialog("_limestone_island.npcs.bernard.3")
  elseif game:get_value("sometimes_spider_dead") == true and game:get_value("sometimes_spider_reward") ~= true then
    game:start_dialog("_limestone_island.npcs.bernard.2")
    game:add_money(30)
    game:set_value("sometimes_spider_reward", true)
  else
    game:start_dialog("_limestone_island.npcs.bernard.1")
  end
end