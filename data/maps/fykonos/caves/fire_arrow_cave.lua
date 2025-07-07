local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(2)
  sol.menu.start(map, lighting_effects)

  if game:get_value"fykonos_fire_arrow_cave_door" then boss:remove() end

end)

function boss:on_dead()
  map:open_doors"boss_door"
end
