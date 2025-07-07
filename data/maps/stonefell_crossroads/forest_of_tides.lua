local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  map:cloud_overlay()
  game:set_world_fall_mode(map:get_world(), "fall")
end)
