require("scripts/multi_events")

local item = ...
local game = item:get_game()


item:register_event("on_created", function(self)
  item:set_savegame_variable("possession_honeycomb")
end)

item:register_event("on_obtained", function(self)
  if game:get_value("quest_ballast_harbor_hornet_honey") == 0 then
    game:set_value("quest_ballast_harbor_hornet_honey", 1)
  end
end)
