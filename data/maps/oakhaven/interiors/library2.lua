local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  map:get_camera():letterbox()

end)
