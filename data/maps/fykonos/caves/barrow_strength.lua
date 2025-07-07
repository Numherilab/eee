local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(2)
  sol.menu.start(map, lighting_effects)
end)

for enemy in map:get_entities_by_type"enemy" do
function enemy:on_dead()
  sol.timer.start(map, 299, function()
    if not map:has_entities("skeleton_boss") then
      sol.audio.play_sound"secret"
      map:open_doors"boss_door"
    end
  end)
end
end
