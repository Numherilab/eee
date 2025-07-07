require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_created", function(self)
  self:set_can_disappear(true)
end)

item:register_event("on_started", function(self)
  item:set_savegame_variable("possession_bread")       --variable
  item:set_amount_savegame_variable("amount_bread")    --amount variable
  item:set_max_amount(game:get_value("max_bread_capacity") or 50)
  item:set_assignable(false)
  item:set_brandish_when_picked(not game:has_item(item:get_name()))
end)

--obtained
item:register_event("on_obtaining", function(self, variant, savegame_variable)
  item:set_brandish_when_picked(false)
  local amounts = {1, 5, 10}
  local amount = amounts[variant]
  if amount == nil then
    error("Invalid variant '" .. variant .. "' for item 'rupee'")
  end

  self:add_amount(amount)
end)

--used
item:register_event("on_using", function(self)
  local heal_amount = 10
  if game:get_value"hard_mode" and game:get_value("hard_mode_healing_items") then heal_amount = 6 end
  if self:get_amount() > 0 and game:get_life() < game:get_max_life() then
    game:add_life(heal_amount)
    self:remove_amount(1)
  else sol.audio.play_sound("no")
  end
  item:set_finished()
end)
