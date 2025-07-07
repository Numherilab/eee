require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_created", function(self)

  item:set_savegame_variable("possession_ironwood_charm")
  item:set_sound_when_brandished(nil)
  item:set_sound_when_picked(nil)
  item:set_shadow(nil)
end)

item:register_event("on_variant_changed", function(self, variant)

end)

item:register_event("on_obtaining", function(self, variant)
  game:set_ability("lift", 2)
  sol.audio.play_sound("treasure")
end)
