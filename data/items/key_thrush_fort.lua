require("scripts/multi_events")

local item = ...
local game = item:get_game()

-- Event called when the game is initialized.

item:register_event("on_created", function(self)
  item:set_savegame_variable("possession_key_thrush_fort")
  item:set_amount_savegame_variable("amount_key_thrush_fort")
end)

item:register_event("on_obtained", function(self)
  self:add_amount(1)
  game:set_value("quest_heron_well", 0)
end)

item:register_event("on_amount_changed", function(self, amount)
  if amount==0 then --trigger quest log update when key is removed after opening door
    game:set_value("possession_key_thrush_fort", nil)
  end
end)
