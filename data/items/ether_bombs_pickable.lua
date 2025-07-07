require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_created", function(self)
  self:set_can_disappear(true)
  item:set_brandish_when_picked(true)
end)

item:register_event("on_obtaining", function(self, variant, savegame_variable)
  item:set_brandish_when_picked(false)
  if not game:has_item("ether_bombs") then
    game:get_item("ether_bombs"):set_variant(1)
  end
  -- Obtaining bombs increases the bombs counter.
  local amounts = {1, 3, 5, 10}
  local amount = amounts[variant]
  if amount == nil then
    error("Invalid variant '" .. variant .. "' for item 'bomb'")
  end
  self:get_game():get_item("ether_bombs"):add_amount(amount)

end)
