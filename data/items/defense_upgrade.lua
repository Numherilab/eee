require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_created", function(self)

  self:set_can_disappear(false)
  self:set_brandish_when_picked(true)
end)

item:register_event("on_obtaining", function(self, variant, savegame_variable)


local  defense = game:get_value("defense")
  game:set_value("defense", defense + 1)


end)
