local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(2)
  sol.menu.start(map, lighting_effects)

  local chest_item = "boomerang"
  local chest_item_variant = 2

  if game:get_item("boomerang"):get_variant() == 2 then
    chest_item = "coral_ore"
    chest_item_variant = 1
  elseif game:get_item("boomerang"):get_variant() == 1 and game:get_value("fykonos_boomerang_stolen_variant") ~= 2 then
    chest_item = "coral_ore"
    chest_item_variant = 1
  elseif game:get_value"fykonos_boomerang_stolen" then
    chest_item = "boomerang"
    chest_item_variant = game:get_value("fykonos_boomerang_stolen_variant")
  else
    chest_item = "coral_ore"
    chest_item_variant = 1
  end

  chest:set_treasure(chest_item, chest_item_variant, "fykonos_boomerang_found")

end)
