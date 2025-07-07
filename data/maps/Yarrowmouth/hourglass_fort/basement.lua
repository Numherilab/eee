local map = ...
local game = map:get_game()
local hero = map:get_hero()
local door_manager = require("scripts/maps/door_manager")
door_manager:manage_map(map)
local in_boss_battle
local crab_spawn_timer

map:register_event("on_started", function()
  map:get_camera():letterbox()

  in_boss_battle = false
  map:open_doors("boss_door_enter")

  if game:get_value("hourglass_fort_boss_defeated") == true then
    boss:set_enabled(false)
  end

  --if you've activated the bridge
  if game:get_value("hourglass_fort_basement_bridge_on") == true then
    for bridge in map:get_entities("bridge") do
     bridge:set_enabled(true)
    end
  end

end)

function talk_sensor:on_activated()
  if game:get_value("hourglass_fort_nobody_home_2") ~= true then
    game:start_dialog("_yarrowmouth.observations.hourglass_fort.nobody_home2")
    game:set_value("hourglass_fort_nobody_home_2", true)
  end
end



function basement_bridge_switch:on_activated()
  sol.audio.play_sound("switch_2")
  game:set_value("hourglass_fort_basement_bridge_on", true)
  for bridge in map:get_entities("bridge") do
   bridge:set_enabled(true)
  end
end

function basement_bridge_2_switch:on_activated()
  sol.audio.play_sound("switch_2")
  game:set_value("hourglass_fort_basement_bridge_on", true)
  for bridge in map:get_entities("2bridge") do
   bridge:set_enabled(true)
  end
end

function basement_elixer_switch:on_activated()
  sol.audio.play_sound("switch_2")
  elixer_bridge:set_enabled(true)
end

function basement_crowns_SE_switch:on_activated()
  sol.audio.play_sound("switch_2")
  basement_crowns_bridge:set_enabled(true)
end


function tower_arrow_switch_A:on_activated()
  map:open_doors("tower_door_A")
end

function basement_arrow_door_switch:on_activated()
  map:open_doors("basement_arrow_door")
end


--boss battle
function enter_boss_room_sensor:on_activated()
  if in_boss_battle == false then
    in_boss_battle = true
    map:close_doors("boss_door_enter")

    --spawn triangle crabs
    crab_spawn_timer = sol.timer.start(map, 7000, function()
      map:create_enemy({
        name = "boss_spawn_crab",
        layer = 0, x = 1048, y = 40,
        direction = 3,
        breed = "normal_enemies/triangle_crab_red"
      })
      map:create_enemy({
        name = "boss_spawn_crab",
        layer = 0, x = 1192, y = 40,
        direction = 3,
        breed = "normal_enemies/triangle_crab_red"
      })
      return true
    end)

  end
end


function boss:on_dead()
  map:create_pickable({
    layer = 0, x = 1120, y = 128, treasure_name = "health_upgrade",
  })

  game:set_value("hourglass_fort_boss_defeated", true)
  map:open_doors("boss_door")
  crab_spawn_timer:stop()

  for enemies in map:get_entities("boss_spawn_crab") do
  enemies:hurt(10) end

end




--end cutscene

--part 1, read the letter
function letter:on_interaction()
  if game:get_value("hourglass_fort_read_letter") ~= true then
    game:start_dialog("_yarrowmouth.observations.hourglass_fort.letter", function()
      game:set_value("quest_log_a", "a8")

      game:set_value("quest_hourglass_fort", 3) --quest log
      game:set_value("quest_hazel", 0) --quest log
      hero:teleport("Yarrowmouth/tern_marsh", "from_hourglass_fort", "fade")
    end)
    game:set_value("hourglass_fort_read_letter", true)
    game:set_value("oakhaven_ferries_activated", true) --this is juuuust in case I used this value somewhere else
  end
end
