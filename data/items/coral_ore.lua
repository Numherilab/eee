require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_started", function(self)
  item:set_savegame_variable("possession_coral_ore")
  item:set_amount_savegame_variable("amount_coral_ore")
end)

item:register_event("on_obtaining", function(self)
  self:add_amount(1)
end)

-- Event called when a pickable treasure representing this item
-- is created on the map.
-- You can set a particular movement here if you don't like the default one.
item:register_event("on_pickable_created", function(self, pickable)

end)
