local map = ...
local game = map:get_game()

for block in map:get_entities"covering_statue" do
function block:on_moving()
  if map:has_entities"hole_blocker" then
    hole_blocker:set_enabled(false)
  end
end
end
