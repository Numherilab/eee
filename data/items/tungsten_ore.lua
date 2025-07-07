require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_created", function(self)
  item:set_savegame_variable("possession_tungsten_ore")
end)

item:register_event("on_obtained", function(self)
  if game:get_value("quest_bomb_arrows") == 1 then
    game:set_value("quest_bomb_arrows", 2)
  end
end)
