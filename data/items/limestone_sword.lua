require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_created", function(self)
  item:set_savegame_variable("possession_limestone_sword")
end)
