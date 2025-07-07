-- Lua script of map oakhaven/caves/westoak_shrine.
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
  lighting_effects:set_darkness_level(3)
  sol.menu.start(map, lighting_effects)

  map:set_doors_open("boss_door_b")
end)

function entered_boss_room_sensor:on_activated()
  map:close_doors("boss_door")
  entered_boss_room_sensor:set_enabled(false)
end

function enemy_a:on_dead()
  map:open_doors("boss_door")
  entered_boss_room_sensor:set_enabled(false)
end

for enemy in map:get_entities("bat") do
  function enemy:on_dead()
    if not map:has_entities("bat") then
      map:open_doors("first_door")
    end
  end
end