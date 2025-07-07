local item = ...
local game = item:get_game()

function item:on_started()
  local name = item:get_name():gsub("/", "_")
  item:set_savegame_variable("possession_" .. name)
end

function item:on_using()
  sol.timer.start(game,200, function()
    print(game:get_hud():is_enabled())
    game:get_hud():set_enabled(not game:get_hud():is_enabled())
    item:set_finished()
  end)
end
