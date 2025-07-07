local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(2)
  sol.menu.start(map, lighting_effects)
end)

function boat_sensor:on_activated()
  game:start_dialog("_ballast_harbor.observations.old_spruce_shrine_leave_dialog", function(answer)
    if answer == 3 then
      hero:teleport("ballast_harbor/willow_palace", "from_outside")
    end
  end)
end
