-- Lua script of map Limestone Island/caves/sanctuary_1.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  self:get_camera():letterbox()

  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function bridge_switch:on_activated()
  sol.audio.play_sound("switch")
  bridge_1:set_enabled(true)
  bridge_2:set_enabled(true)
  bridge_3:set_enabled(true)
  bridge_4:set_enabled(true)
  bridge_5:set_enabled(true)
  bridge_6:set_enabled(true)

end

function observation_sensor:on_activated()
  if game:get_value("limestone_sanctuary_observation") ~= true then
    game:start_dialog("_limestone_island.observations.sanctuary")
    game:set_value("limestone_sanctuary_observation", true)
  end
end