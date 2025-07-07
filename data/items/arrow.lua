require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_created", function(self)

  self:set_shadow("small")
  self:set_can_disappear(true)
  self:set_brandish_when_picked(false)

end)

item:register_event("on_obtaining", function(self, variant, savegame_variable)
  -- Obtaining arrows increases the counter of the bow.
  local amounts = { 1, 3, 5, 10, 20 }
  local amount = amounts[variant]
  if amount == nil then
    error("Invalid variant '" .. variant .. "' for item 'arrow'")
  end

  game:get_item("bow"):add_amount(amount)

end)
