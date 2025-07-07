require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_created", function(self)
  self:set_can_disappear(true)
end)

item:register_event("on_started", function(self)
  item:set_savegame_variable("possession_berries")
  item:set_amount_savegame_variable("amount_berries")
  item:set_max_amount(game:get_value("max_berry_capacity") or 50)
  item:set_assignable(false)
  item:set_brandish_when_picked(not game:has_item(item:get_name()))
end)

--obtained
item:register_event("on_obtaining", function(self, variant, savegame_variable)
  item:set_brandish_when_picked(false)
  local amounts = {1, 3, 5, 20}
  local amount = amounts[variant]
  if amount == nil then
    error("Invalid variant '" .. variant .. "' for item 'berries'")
  end

  self:add_amount(amount)
end)

--used
item:register_event("on_using", function(self)
  if self:get_amount() > 0 and game:get_life() < game:get_max_life() then
    game:add_life(1)
    self:remove_amount(1)
  else
    sol.audio.play_sound("no")
  end
  item:set_finished()
end)
