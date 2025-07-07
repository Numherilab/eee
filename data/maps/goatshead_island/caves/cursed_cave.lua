local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(2)
  sol.menu.start(map, lighting_effects)
end)

for enemy in map:get_entities"boss" do
function enemy:on_dead()
  if not map:has_entities"boss" then
    map:open_doors"door"
    for e in map:get_entities"turret" do e:remove_life(100) end
  end
end
end