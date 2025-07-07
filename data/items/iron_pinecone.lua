require("scripts/multi_events")

local item = ...
local game = item:get_game()


item:register_event("on_created", function(self)
  item:set_savegame_variable("possession_iron_pinecone")
end)

item:register_event("on_obtained", function(self)
  game:set_value("quest_iron_pine_cone", 1)
end)
