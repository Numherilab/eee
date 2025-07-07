-- Lua script of map Yarrowmouth/caves/dandelion_charm_cave.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local enemies_killed

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(2)
  sol.menu.start(map, lighting_effects)

  enemies_killed = 0
end)


function door_switch_1:on_activated()
  map:open_doors("shutter_door")
end

for enemy in map:get_entities("room_1_enemy") do
  function enemy:on_dead()
    enemies_killed = enemies_killed + 1
    if enemies_killed == 2 then
      map:open_doors("room_1_door")
    end
  end
end
