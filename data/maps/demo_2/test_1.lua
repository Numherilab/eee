local map = ...
local game = map:get_game()

function map:on_started()
  game:get_hud():set_enabled(false)
end


function map:on_opening_transition_finished()

end
