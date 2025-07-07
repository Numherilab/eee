-- Lua script of map Yarrowmouth/caves/village_cave.
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
  lighting_effects:set_darkness_level(4)
  sol.menu.start(map, lighting_effects)

  map:set_doors_open("boss_door")
end)

function boss_sensor:on_activated()
  map:close_doors("boss_door")
  boss_sensor:set_enabled(false)
end

for boss in map:get_entities("boss_enemy") do
  function boss:on_dead()
    if not map:has_entities("boss_enemy") then
      sol.audio.play_sound("secret")
      map:focus_on(map:get_camera(), boss_door_4, function()
        map:open_doors("boss_door")
      end)
    end
  end
end

function exit_switch:on_activated()
  map:open_doors("exit_door")
end