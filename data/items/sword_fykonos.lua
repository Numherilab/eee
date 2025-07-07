local item = ...
local game = item:get_game()

function item:on_started()
  item:set_savegame_variable("possession_sword_fykonos")
end


function item:on_obtained()
  game:set_ability("sword", 1)
end
