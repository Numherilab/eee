local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(3)
  sol.menu.start(map, lighting_effects)

  if game:get_value("quest_ivy_orchard") >= 3 then
    for enemy in map:get_entities_by_type("enemy") do enemy:set_enabled(false) end
    map:set_doors_open("boss_door")
    for box in map:get_entities("apple_box") do box:set_enabled(true) end
  end
end)


function boss:on_dead()
  map:open_doors("boss_door")
end

function paul:on_interaction()
  if game:get_value("quest_ivy_orchard") < 3 then
    game:start_dialog("_oakhaven.npcs.ivystump.picker_paul.4", function()
      game:set_value("quest_ivy_orchard", 3)
      game:add_money(120)
    end)
  else
    game:start_dialog("_oakhaven.npcs.ivystump.picker_paul.5")
  end
end
