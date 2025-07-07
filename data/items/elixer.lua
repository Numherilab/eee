require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_started", function(self)
  item:set_savegame_variable("possession_elixer")
  item:set_amount_savegame_variable("amount_elixer")
  item:set_max_amount(99)
  item:set_assignable(false)
end)

item:register_event("on_obtaining", function(self)
  item:set_brandish_when_picked(false)
  self:add_amount(1)
end)


item:register_event("on_using", function(self)
  if self:get_amount() > 0 and game:get_life() < game:get_max_life() then
    game:add_life(game:get_value("elixer_restoration_level") * 2)
    self:remove_amount(1)
    sol.audio.play_sound("uncorking_and_drinking_1")
  else sol.audio.play_sound("no")
  end
  item:set_finished()
end)
