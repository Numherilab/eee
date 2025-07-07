local map = ...
local game = map:get_game()


map:register_event("on_started", function()

end)

function exit_switch:on_activated()
  sol.audio.play_sound"switch"
  map:open_doors("exit_door")
end

