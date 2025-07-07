local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(2+1)
  sol.menu.start(map, lighting_effects)

  if game:get_value"fykonos_not_demo" then
    chest:set_treasure("coral_ore", 1, "fykonos_amalenchier_treasure")
  end

end)

