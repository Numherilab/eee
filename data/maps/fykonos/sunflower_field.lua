local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  if game:get_value"fykonos_saw_sunflower_goblin" then
    goblin:remove()
    goblin_sensor:remove()
  end
end)

function goblin_sensor:on_activated()
  goblin_sensor:remove()
  sol.audio.play_sound"goblin_giggle"
  local m = sol.movement.create"path"
  m:set_path{4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4}
  m:set_speed(100)
  m:set_ignore_obstacles(true)
  m:start(goblin, function() goblin:remove() end)
  game:set_value("fykonos_saw_sunflower_goblin", true)
end
