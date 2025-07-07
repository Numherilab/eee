require("scripts/multi_events")

local item = ...
local game = item:get_game()

-- Event called when the game is initialized.
item:register_event("on_created", function(self)
  item:set_savegame_variable("possession_bomb_arrow_ticket")
end)

item:register_event("on_obtained", function(self)
  game:set_value("quest_bomb_arrows", 0) --quest log
end)
