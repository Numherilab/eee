local save_menu = {}

function save_menu:on_started()
  local game = sol.main:get_game()
  game:start_dialog("_game.pause", function(answer)
    if answer == 1 then
      game:set_paused(false)
    elseif answer == 2 then
      game:save()
      sol.audio.play_sound("elixer_upgrade")
      game:set_paused(false)
    elseif answer == 3 then
      sol.timer.start(sol.main, 20, function() sol.main.reset() end)
    end
  end)
end

return save_menu