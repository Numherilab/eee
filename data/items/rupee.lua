require("scripts/multi_events")

local item = ...

item:register_event("on_created", function(self)

  self:set_shadow("small")
  self:set_can_disappear(true)
  self:set_brandish_when_picked(false)
  self:set_sound_when_picked("picked_rupee")
end)

item:register_event("on_obtaining", function(self, variant, savegame_variable)

  local amounts = {5, 10, 20, 50, 100, 200, 500, 1000}
  local amount = amounts[variant]
  if amount == nil then
    error("Invalid variant '" .. variant .. "' for item 'rupee'")
  end
  self:get_game():add_money(amount)
end)
