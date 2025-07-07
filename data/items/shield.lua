require("scripts/multi_events")

local item = ...

item:register_event("on_created", function(self)

  self:set_savegame_variable("possession_shield")
  self:set_sound_when_picked(nil)
end)

item:register_event("on_variant_changed", function(self, variant)
  -- The possession state of the shield determines the built-in ability "shield".
  self:get_game():set_ability("shield", variant)
end)
