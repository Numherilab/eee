require("scripts/multi_events")

local item = ...
local game = item:get_game()


item:register_event("on_started", function(self)
  item:set_savegame_variable("found_heron_door_marble_summit")
end)
