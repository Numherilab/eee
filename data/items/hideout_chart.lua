require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_created", function(self)
  item:set_savegame_variable("possession_hideout_chart")

end)


item:register_event("on_pickable_created", function(self, pickable)

end)
