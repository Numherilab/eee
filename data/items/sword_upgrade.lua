require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_created", function(self)

  self:set_can_disappear(false)
  self:set_brandish_when_picked(true)
end)

item:register_event("on_obtaining", function(self, variant, savegame_variable)

  local sword_damage =   game:get_value("sword_damage")
  game:set_value("sword_damage", sword_damage + 1)
end)
