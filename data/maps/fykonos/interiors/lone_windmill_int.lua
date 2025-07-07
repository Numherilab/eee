local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  map:set_doors_open"blockuin"
end)

function trapu_sensor:on_activated()
  trapu_sensor:remove()
  map:close_doors"blockuin"
end

function fire_sensor:on_collision_fire()
  torch:set_enabled()
  sol.audio.play_sound"secret"
  map:open_doors"blockuin"
end

