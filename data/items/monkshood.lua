require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_started", function(self)
  item:set_savegame_variable("possession_monkshood")
  item:set_amount_savegame_variable("amount_monkshood")
end)

item:register_event("on_obtaining", function(self)
  self:add_amount(1)
  if game:get_value("quest_monkshood") then game:set_value("quest_monkshood", 1) end
end)

-- Event called when a pickable treasure representing this item
-- is created on the map.
-- You can set a particular movement here if you don't like the default one.
item:register_event("on_pickable_created", function(self, pickable)

end)
