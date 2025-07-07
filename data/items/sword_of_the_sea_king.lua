require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_created", function(self)
  item:set_savegame_variable("possession_sword_of_the_sea_king")
  self:set_can_disappear(false)
  self:set_brandish_when_picked(true)
  item:set_sound_when_brandished("piece_of_heart")
  item:set_sound_when_picked("piece_of_heart")
end)

item:register_event("on_obtaining", function(self, variant, savegame_variable)
  game:set_value("sword_damage", game:get_value("sword_damage") + 2)
--  game:set_ability("sword_knowledge", 1)
end)
