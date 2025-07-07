local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(2)
  sol.menu.start(map, lighting_effects)
end)

for switch in map:get_entities"b1_switch" do
  function switch:on_activated()
    map:open_doors"b1_door"
    sol.timer.start(map, 200, function()
      for other_switch in map:get_entities"b1_switch" do
        if not other_switch:is_activated() then
          switch:set_activated(false)
          map:close_doors"b1_door"
        end
      end
    end)
  end
end