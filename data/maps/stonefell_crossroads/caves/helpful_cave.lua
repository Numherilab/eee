local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(1)
  sol.menu.start(map, lighting_effects)
end)

for statue in map:get_entities"statue" do
function statue:on_interaction()
  game:start_dialog("_oakhaven.observations.misc.llama", function()
    game:set_life(game:get_max_life())
  end)
end
end
