-- Lua script of map oakhaven/caves/umber_lake.
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
end)

function coral_boss:on_dead()
  map:open_doors("coral_ore_door")
end

function brass_door:on_opened()
  if game:get_value("quest_abyss") == 0 then
    game:set_value("quest_abyss", 1)
  end
end

--map banner
for activator in map:get_entities("map_banner_activator") do
function activator:on_activated()
  for sensor in map:get_entities("^map_banner_sensor") do
    sensor:set_enabled(true)
    sol.timer.start(map, 2000, function() sensor:set_enabled(false) end)
  end
  activator:set_enabled(false)
end
end

