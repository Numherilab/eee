require("scripts/multi_events")

local item = ...
local game = item:get_game()

-- Event called when the game is initialized.

item:register_event("on_created", function(self)
  item:set_savegame_variable("possession_key_poplar_shack")
  item:set_amount_savegame_variable("amount_key_poplar_shack")
end)

item:register_event("on_obtained", function(self)
  game:set_value("quest_poplar_shack_lost_key", 0)
  self:add_amount(1)
end)
