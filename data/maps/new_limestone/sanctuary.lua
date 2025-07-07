-- Lua script of map new_limestone/sanctuary.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(1)
  sol.menu.start(map, lighting_effects)
end)

function ob_sensor:on_activated()
  if not game:get_value("limestone_seen_sanctuary_state") then
    game:start_dialog("_limestone_island.observations.sanctuary")
    game:set_value("limestone_seen_sanctuary_state", true)
    ob_sensor:remove()
  end
end