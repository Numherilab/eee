-- Lua script of map Yarrowmouth/caves/deuling_arborgeist_cave.
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

  sol.timer.start(map, 500, function()
    if not map:has_entities"arborgeist" then
      map:open_doors("wholeway_door")
    else
      return true
    end
  end)
end)

for enemy in map:get_entities("arborgeist") do
  function enemy:on_dead()
    if map:has_entities"arborgeist" then
      map:open_doors"halfway_door"
    end
  end
end

