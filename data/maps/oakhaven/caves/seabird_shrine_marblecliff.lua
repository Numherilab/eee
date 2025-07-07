-- Lua script of map Yarrowmouth/caves/seabird_shrine.
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


for enemy in map:get_entities("boss") do
  function enemy:on_dead()
    if not map:has_entities("boss") and not game:get_value("marblecliff_seabird_upgrade_received") then
      for projectile in map:get_entities_by_type("enemy") do
        projectile:remove()
      end
      local x, y, l = emblem:get_position()
      game:set_life(game:get_max_life())
      local zapper = game:get_item("thunder_charm")
      map:create_pickable({
        x = x + 8, y = y + 8, layer = l,
        treasure_name = "thunder_charm", treasure_variant = zapper:get_variant() + 1,
        treasure_savegame_variable = "marblecliff_seabird_upgrade_received",
      })
    end
  end
end