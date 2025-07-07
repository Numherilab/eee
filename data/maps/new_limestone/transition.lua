local map = ...
local game = map:get_game()

function map:on_started()
  proceed_warp:set_enabled(false)

end

function map:on_opening_transition_finished()
  game:start_dialog("_new_limestone_island.one_year_later", function()
    proceed_warp:set_enabled(true)
  end)
end
