local map = ...
local game = map:get_game()

function rope_switch:on_activated()
  local m1 = sol.movement.create("path")
  m1:set_path{4,4,4,4}
  local m2 = sol.movement.create("path")
  m2:set_path{4,4,4,4}
  m1:start(rope)
  m2:start(hook)
end
