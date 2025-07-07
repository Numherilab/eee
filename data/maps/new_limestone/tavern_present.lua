
local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  if game:get_value("briarwood_distillery_quest_complete") == true then
    for entity in map:get_entities("briarwood_gin") do
      entity:set_enabled(true)
    end
  end

end)


-- Mandatory Linden Talk
function talk_to_linden_sensor:on_activated()
local linden_check = game:get_value("linden_dialog_check")
if linden_check ~= true then
  local see_linden_movement = sol.movement.create("target")
  hero:freeze()
  see_linden_movement:set_target(112,96)
  see_linden_movement:set_ignore_obstacles(true)
  hero:set_direction(0)
  linden_movement = sol.movement.create("path")
  linden_movement:set_path{4}
  linden_movement:start(linden)
  hero:set_animation("walking")
  see_linden_movement:start(hero, function()
    game:start_dialog("_new_limestone_island.npcs.linden.4", function()
      if game:has_item("sword") == true then
        game:start_dialog("_new_limestone_island.npcs.linden.7")
        game:set_value("quest_meet_juglan_at_pier", 0) --quest log
      else
        game:start_dialog("_new_limestone_island.npcs.linden.6")
        game:set_value("quest_meet_juglan_at_pier", 0) --quest log
      end
      hero:unfreeze()
      game:set_value("linden_dialog_check", true)
    end)

  end)
end
end

function linden:on_interaction()
  if game:get_value"quest_isle_of_storms" then
    game:start_dialog"_new_limestone_island.npcs.linden.plot_updates.isle_of_storms"

  elseif game:get_value"quest_snapmast" then
    game:start_dialog"_new_limestone_island.npcs.linden.plot_updates.snapmast"

  elseif game:get_value"quest_pirate_fort" then
    game:start_dialog"_new_limestone_island.npcs.linden.plot_updates.fort_crow"

  elseif game:get_value"quest_hazel" then
    game:start_dialog"_new_limestone_island.npcs.linden.plot_updates.oakhaven"

  elseif game:get_value"quest_kelpton" and game:get_value"quest_kelpton" >= 4 then
    game:start_dialog"_new_limestone_island.npcs.linden.plot_updates.catacombs"

  else
    game:start_dialog("_new_limestone_island.npcs.linden.5")
  end
end
