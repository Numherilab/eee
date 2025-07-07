local map = ...
local game = map:get_game()


function arrow_switch:on_activated()
  map:focus_on(map:get_camera(), barrow_door, function()
    map:open_doors"barrow_door"
    sol.audio.play_sound"secret"
  end)
end

