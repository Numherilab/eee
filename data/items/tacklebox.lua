require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_created", function(self)

  item:set_savegame_variable("possession_tacklebox")
end)

item:register_event("on_variant_changed", function(self, variant)
  game:set_value("talked_to_wally", 2)
end)
