local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(2)
  sol.menu.start(map, lighting_effects)

  if game:get_value"fykonos_fire_arrow_cave_door" then boss:remove() end

end)

local goblin = map:get_entity("^lighting_effect_candle_goblin")
function goblin:on_dead()
   local x, y, z = 192, 140, 0
   map:create_poof(x, y, z)
   goblin = map:create_enemy{x=x, y=y, z=z, layer=0, direction=2, breed="normal_enemies/ophira_goblin", name="^lighting_effect_goblin"}
end