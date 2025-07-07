local map = ...
local game = map:get_game()

function map:on_started()
  game:start_dialog("_game.corrupted_save", function()
    sol.timer.start(sol.main, 20, function() sol.main.reset() end)
  end)
  sol.timer.start(sol.main, 2000, function() sol.main.reset() end)
end