-- Lua script of map Limestone Island/limestone_mountain.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  if game:get_value("limestone_lighthouse_lit") == true then
    lighthouse_torch:set_enabled(true)
  end
  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function flower_observation:on_activated()
  if game:get_value("limestone_flower_observation") ~= true then
    game:start_dialog("_limestone_island.observations.flowers")
    game:set_value("limestone_flower_observation", true)
  end

end

function training_observation:on_activated()
  if game:get_value("limestone_training_observation") ~= true then
    game:start_dialog("_limestone_island.observations.training")
    game:set_value("limestone_training_observation", true)
  end

end