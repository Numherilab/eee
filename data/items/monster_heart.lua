require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_started", function(self)
  item:set_savegame_variable("possession_monster_heart")
  item:set_amount_savegame_variable("amount_monster_heart")
  item:set_brandish_when_picked(not game:has_item(item:get_name()))
end)

item:register_event("on_obtaining", function(self, variant, savegame_variable)
  if game:has_item(item:get_name()) then item:set_brandish_when_picked(false) end
  self:add_amount(1)
end)

item:register_event("on_pickable_created", function(self, pickable)

end)
