require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_created", function(self)

  self:set_can_disappear(false)
  self:set_brandish_when_picked(true)
end)

--Increase sword and bow damage by 1 each.
item:register_event("on_obtaining", function(self, variant, savegame_variable)
  game:set_value("sword_damage", game:get_value("sword_damage") + variant)
  game:set_value("bow_damage", game:get_value("bow_damage") + variant)
--  print(game:get_value("sword_damage")) print(game:get_value("bow_damage"))

end)
