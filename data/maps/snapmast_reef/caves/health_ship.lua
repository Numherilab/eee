-- Lua script of map snapmast_reef/caves/health_ship.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
  require("scripts/fx/sound_atmosphere_manager"):start_atmosphere(map, "rain_inside")
end)


for enemy in map:get_entities("enemy") do
  function enemy:on_dead()
    if game:get_value("snapmast_health_ship_upgrade") == nil and map:has_entities("enemy") == false then
      sol.audio.play_sound("secret")
      health:set_enabled(true)
    end
  end
end
