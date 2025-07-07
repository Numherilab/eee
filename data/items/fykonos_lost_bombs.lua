require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_created", function(self)
  self:set_shadow("small")
  self:set_brandish_when_picked(false)
end)

item:register_event("on_obtaining", function(self, variant, savegame_variable)
  local amount = game:get_value("fykonos_amount_bombs_stolen") or 1
  game:get_item("bombs_counter_2"):add_amount(amount)
end)
