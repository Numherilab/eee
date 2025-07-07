require("scripts/multi_events")

local item = ...
local game = item:get_game()

-- Event called when the game is initialized.
item:register_event("on_created", function(self)
  item:set_savegame_variable("possession_crow_feather")

end)

item:register_event("on_pickable_created", function(self, pickable)

end)

item:register_event("on_obtained", function(self)
  if not game:get_value("quest_crow_lord") then
    game:set_value("quest_crow_lord", 0)
  end
end)
