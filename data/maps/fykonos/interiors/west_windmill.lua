local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(1)
  sol.menu.start(map, lighting_effects)

  pull_blocker:set_traversable_by("hero", function()
    return not (hero:get_state() == "pulling")
  end)

end)
