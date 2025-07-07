require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_created", function(self)
  self:set_can_disappear(true)
  self:set_brandish_when_picked(true)
end)

item:register_event("on_started", function(self)
  item:set_savegame_variable("possession_soup")       --variable
  item:set_amount_savegame_variable("amount_soup")    --amount variable
  item:set_max_amount(999)
  item:set_assignable(true)
end)

--obtained
item:register_event("on_obtaining", function(self, variant, savegame_variable)
  self:add_amount(1)
end)

--used
item:register_event("on_using", function(self)
  if self:get_amount() > 0 then
    game:add_life(10)              --health amount!
    self:remove_amount(1)
  end
  item:set_finished()
end)
