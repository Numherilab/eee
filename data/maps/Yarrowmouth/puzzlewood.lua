local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  require("scripts/fx/sound_atmosphere_manager"):start_atmosphere(map, "birds")

  --footprints
  if game:get_value("puzzlewood_footprints_visible") == true then
    for prints in map:get_entities("footprints") do
      prints:set_enabled(true)
    end
  else
    for prints in map:get_entities("footprints") do
      prints:set_enabled(false)
    end
  end


  --mushroom spot
  if game:get_value("rohit_dialog_counter") ~= nil and game:get_value("rohit_dialog_counter") >= 2 then
    for entity in map:get_entities("mushroom_golem") do
      entity:set_enabled(false)
    end
  end

end)


function trap_sensor:on_activated()
  if game:get_value("rohit_dialog_counter") < 2 then
    map:close_doors("gate")
    trap_you_in_ambush_wall:set_enabled(true)
    game:start_dialog("_yarrowmouth.observations.ambush_2")
  end
end

for golem in map:get_entities("mushroom_golem") do
  function golem:on_dead()
    if map:get_entities_count("mushroom_golem") == 0 then
      game:start_dialog("_yarrowmouth.observations.mushroom_spot.1", function()
        trap_you_in_ambush_wall:set_enabled(false)
        game:set_value("quest_briarwood_mushrooms", 1) --quest log
        game:set_value("rohit_dialog_counter", 2)
        game:set_value("puzzlewood_footprints_visible", true)
        map:open_doors("gate")
        for prints in map:get_entities("footprints") do
          prints:set_enabled(true)
        end
      end)
    end
  end
end

