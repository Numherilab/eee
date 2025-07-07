-- Lua script of map oakhaven/interiors/haunted_house.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(5)
  sol.menu.start(map, lighting_effects)

  if game:get_value("oakhaven_haunted_house_ghost_defeated") then
    grim:set_enabled(false)
    map:open_doors("treasure_door")
  end
end)

function grim:on_dead()
  map:get_entity("^lighting_effect_torch_1"):set_enabled()
  map:open_doors("treasure_door") 
  game:set_value("oakhaven_haunted_house_ghost_defeated", true)
end