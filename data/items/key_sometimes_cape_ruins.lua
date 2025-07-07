require("scripts/multi_events")

local item = ...
local game = item:get_game()

-- Event called when the game is initialized.

item:register_event("on_created", function(self)
  item:set_savegame_variable("possession_key_sometimes_cape_ruins")
  item:set_amount_savegame_variable("amount_key_sometimes_cape_ruins")
end)

item:register_event("on_obtained", function(self)
  self:add_amount(1)
end)
