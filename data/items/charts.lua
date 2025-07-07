require("scripts/multi_events")

local item = ...
local game = item:get_game()


item:register_event("on_created", function(self)
  item:set_savegame_variable("possession_charts")
end)

item:register_event("on_obtained", function(self)
  game:set_value("quest_kelpton", 3)
end)
