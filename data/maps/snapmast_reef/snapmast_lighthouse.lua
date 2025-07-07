-- Lua script of map snapmast_reef/snapmast_lighthouse.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()


map:register_event("on_started", function()
  require("scripts/fx/sound_atmosphere_manager"):start_atmosphere(map, "rain")
  local world = map:get_world()
  game:set_world_rain_mode(world, "storm")

  if game:get_value("snapmast_lighthouse_lit") then
    for light in map:get_entities("lighthouse_light") do
      light:set_enabled(true)
    end
  end
end)