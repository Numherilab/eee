local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  require("scripts/fx/sound_atmosphere_manager"):start_atmosphere(map, "rain")
  local world = map:get_world()
  game:set_world_rain_mode(world, "storm")

  sol.timer.start(map, 0, function()
    sol.audio.play_sound"ship_creak_6s"
    return 6000
  end)

  if game:get_item("bombs_counter_2"):get_amount() < 11 then
    game:get_item("bombs_counter_2"):set_amount(10) end
  if game:get_item("bow"):get_amount() < 21 then
    game:get_item("bow"):set_amount(20) end
  if game:get_item("berries"):get_amount() < 8 then
    game:get_item("berries"):set_amount(8)
  end

end)


--Enemy wave 1
map:register_event("on_opening_transition_finished", function()
  for i=1, (2+1) do
    local spawn_point = map:get_entity("spawn_point_" .. i)
    local x,y,z = spawn_point:get_position()
    map:create_poof(x,y+2,z)
    map:create_enemy{x=x,y=y,layer=z,direction=0,
      name = "wave_1_enemy",
      breed="normal_enemies/seaweed_blob"}
  end

  sol.timer.start(map, 100, function()
    if not map:has_entities"wave_1_enemy" then
      map:wave_2()
    else
      return true
    end
  end)
end)


--Enemy wave 2
function map:wave_2()
  if not game:get_value"fykonos_not_demo" then
    game:get_dialog_box():set_style("empty")
    game:start_dialog("_fykonos.observations.tutorial.equip", function()
      game:get_dialog_box():set_style("box")
    end)
  end
    sol.audio.play_sound"monster_scream"
    sol.audio.play_music"boss_battle"

    --enable head
    seamonster:get_sprite():set_animation("underwater")
    seamonster:set_enabled(true)
    seamonster:surface()

    --create tentacles
    for i=1, 5 do
      local spawn_point = map:get_entity("tentacle_spawn_point_" .. i)
      local x,y,z = spawn_point:get_position()
      map:create_poof(x,y+2,z)
      map:create_enemy{x=x,y=y,layer=z,direction=0,
        name = "wave_2_enemy",
        breed="misc/seamonster_tentacle"}
    end

  sol.timer.start(map, 100, function()
    if not map:has_entities"wave_2_enemy" then
      map:wave_4()
      seamonster:dive()
    else
      return true
    end
  end)
end


--Enemy wave 4
--There is no three. The three key is broken.
function map:wave_4()
  --Create other monsters while seamonster rests
  for i=1, 2 do
    local spawn_point = map:get_entity("spawn_point_" .. i)
    local x,y,z = spawn_point:get_position()
    map:create_poof(x,y+2,z)
    local ghost = map:create_enemy{x=x,y=y,layer=z,direction=0,
      name = "wave_4_enemy",
      breed="normal_enemies/ophira_goblin"}
    ghost:set_damage(4)
  end

  sol.timer.start(map, 100, function()
    if not map:has_entities"wave_4_enemy" then
      map:wave_5()
    else
      return true
    end
  end)
end



function map:wave_5()
    sol.audio.play_sound"monster_scream"

    --enable head
    seamonster:get_sprite():set_animation("underwater")
    seamonster:surface()

    --create tentacles
    for i=1, 5 do
      local spawn_point = map:get_entity("tentacle_spawn_point_" .. i)
      local x,y,z = spawn_point:get_position()
      map:create_poof(x,y+2,z)
      map:create_enemy{x=x,y=y,layer=z,direction=0,
        name = "wave_5_enemy",
        breed="misc/seamonster_tentacle"}
    end

  sol.timer.start(map, 100, function()
    if not map:has_entities"wave_5_enemy" then
      map:shipwreck()
      seamonster:dive()
    else
      return true
    end
  end)
end



function map:shipwreck()
    sol.audio.play_sound"thunk1"
    sol.audio.play_sound"switch_2"
    sol.audio.play_sound"hand_cannon"
    map:fade_in_music()

    sol.timer.start(map, 1000, function()
      game:start_dialog("_fykonos.observations.shipwreck.enemies_defeated", function()
        game:set_value("fykonos_ship_defended", true)
        tele:set_enabled(true)
      end)
    end)
end

