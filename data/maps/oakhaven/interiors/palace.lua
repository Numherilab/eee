local map = ...
local game = map:get_game()
local hero = map:get_hero()

map:register_event("on_started", function()
  if game:get_value("mayors_dog_quest_cant_check_litton") == true then
    cant_check_litton_sensor:set_enabled(true)
  end
  if game:get_value("quest_mayors_dog") and game:get_value("quest_mayors_dog") >= 5 then
    attic_guard:set_enabled(false)
    litton:set_enabled(false)
  end
  if game:get_value("quest_mayors_dog") and game:get_value("quest_mayors_dog") > 6 then
    troll:set_enabled(false)
  end
  if game:get_value("quest_mayors_dog") and game:get_value("quest_mayors_dog") >= 11 then
    dog_painting_attic:set_enabled(false)
    attic_painting:set_enabled(false)
    downstairs_dog_painting:set_enabled(true)
  end
  if game:get_value("oakhaven_palace_rune_activated") then glowing_rune:set_enabled(true) end

  --new hazel interaction stuff
  if game:get_value("quest_hazel") == 6 then
    new_hazel:remove()
    found_hazel_sensor:remove()
    for pirate in map:get_entities("pirate") do pirate:set_enabled() end
  elseif game:get_value("quest_hazel") == 7 then
    new_hazel:remove()
    found_hazel_sensor:remove()
    for pirate in map:get_entities("pirate") do pirate:set_enabled(false) end
  else
    for pirate in map:get_entities("pirate") do pirate:set_enabled(false) end
  end

  --moved to gardens:
  if game:get_value("quest_mayors_dog") and game:get_value("quest_mayors_dog") >= 7 and game:get_value("quest_mayors_dog") < 11 then
    happy_mayor:set_enabled(false)
    sad_mayor:set_enabled(true)
    dog:set_enabled(false)
  end


end)




--MAYOR'S DOG'S BIRTHDAY PARTY QUEST
for npc in map:get_entities("clue_npc") do
  function npc:on_interaction()
    if not game:get_value("quest_mayor_dog_clue_npc"..npc:get_name().."spoken_to") then

      if game:get_value("mayors_dog_clue_npcs_spoken_to") == nil then
        game:start_dialog("_oakhaven.npcs.mayors_party.clues.1", function()
          game:set_value("mayors_dog_clue_npcs_spoken_to", 1)
          game:set_value("quest_mayors_dog", 2)
        end)

      elseif game:get_value("mayors_dog_clue_npcs_spoken_to") == 1 then
        game:start_dialog("_oakhaven.npcs.mayors_party.clues.2", function()
          game:set_value("mayors_dog_clue_npcs_spoken_to", 2)
          game:set_value("quest_mayors_dog", 3)
        end)

      elseif game:get_value("mayors_dog_clue_npcs_spoken_to") == 2 then
        game:start_dialog("_oakhaven.npcs.mayors_party.clues.3", function()
          game:set_value("mayors_dog_clue_npcs_spoken_to", 3)
          game:set_value("quest_mayors_dog", 4)
        end)

      end --end which npc this is
      game:set_value("quest_mayor_dog_clue_npc"..npc:get_name().."spoken_to", true)

    else --if you've already received this clue
      game:start_dialog("_oakhaven.npcs.mayors_party.clues.spoken_to_already")

    end
  end
end


function litton:on_interaction()
  if game:get_value("quest_mayors_dog") < 4 then
    game:start_dialog("_oakhaven.npcs.mayors_party.litton.1")

  elseif game:get_value("quest_mayors_dog") == 4 then
    hero:freeze()
    game:start_dialog("_oakhaven.npcs.mayors_party.litton.2-confrontation", function()
      quirrel_guard:set_enabled(true)
      attic_guard:set_enabled(false)
      local m = sol.movement.create("path")
      m:set_speed(90)
      m:set_path{4,4,4,4,4,4,4,4,4,4,}
      m:start(quirrel_guard, function()
        game:start_dialog("_oakhaven.npcs.mayors_party.litton.3-troll_in_dungeon", function()
          m = sol.movement.create("target")
          m:set_target(tile_target)
          m:set_speed(85)
          m:set_smooth(true)
          m:set_ignore_obstacles()
          hero:set_direction(0)
          hero:set_animation("walking")
          m:start(hero, function()
            game:set_value("quest_mayors_dog", 5)
            litton:set_enabled(false)
            quirrel_guard:set_enabled(false)
            cant_check_litton_sensor:set_enabled(true)
            game:set_value("mayors_dog_quest_cant_check_litton", true)
            troll:set_enabled(true)
            hero:unfreeze()
          end)
        end)
      end)
    end)
  end
end

function cant_check_litton_sensor:on_activated()
  game:start_dialog("_oakhaven.npcs.mayors_party.protect_guests")
  hero:walk("00")
end

function troll:on_dead()
  game:set_value("quest_mayors_dog", 6)
  cant_check_litton_sensor:set_enabled(false)
  happy_mayor:set_enabled(false)
  sad_mayor:set_enabled(true)
  dog:set_enabled(false)
  game:set_value("mayors_dog_quest_cant_check_litton", false)
  litton_gone_guard:set_enabled(true)
  litton_gone_guard:on_interaction()
end

function litton_gone_guard:on_interaction()
  hero:freeze()
  hero:set_direction(0)
  local m = sol.movement.create"path"
  m:set_path{2,2,2,2,2,2,4,4}
  m:set_ignore_obstacles()
  m:set_speed(90)
  m:start(litton_gone_guard, function()
    game:start_dialog("_oakhaven.npcs.mayors_party.guards.litton_gone", function()
      m:set_path{0,0,6,6,6,6,6,6}
      m:start(litton_gone_guard, function()
        game:set_value("quest_mayors_dog", 7)
        litton_gone_guard:set_enabled(false)
        hero:unfreeze()
      end)
    end)
  end)
end




---REVISED SECRET ARCHIVES QUEST-----------------------------
function found_hazel_sensor:on_activated()
  game:set_value("found_hazel_in_archives", true) --needed to make Hazel appear in inn
  found_hazel_sensor:remove()
  hero:freeze()
  hero:set_animation("walking")
  local m = sol.movement.create("path")
  m:set_path{2,1,1,2,2,2,2,2,2,2,2}
  m:set_speed(80)
  m:start(hero, function()
    new_hazel:get_sprite():set_direction(3)
    hero:set_animation"stopped"
    map:talk_to_hazel()
  end)
end

function map:talk_to_hazel()
  game:start_dialog("_oakhaven.npcs.hazel.new_library.1", function()
    for pirate in map:get_entities("ambush_pirate") do
      hero:set_direction(3)
      pirate:set_enabled()
      local m = sol.movement.create("target")
      m:set_speed(90)
      m:set_target(map:get_entity("random_pirate_target_" .. math.random(1,8)))
      m:start(pirate)
    end
    sol.timer.start(map, 900, function()
      game:start_dialog("_oakhaven.npcs.hazel.new_library.2", function()
        game:set_value("quest_hazel", 6) --quest log
        hero:unfreeze()
        map:hazel_runs_away()
      end)
    end)

  end)
end

function map:hazel_runs_away()
  local m = sol.movement.create"path"
  m:set_path{6,6,6,6,6,6,6,6,5,5,6,6,6,6}
  m:set_ignore_obstacles()
  m:set_speed(85)
  m:start(new_hazel, function()
    new_hazel:remove()
  end)
end






---------------MISC------------------
function runic_stone:on_interaction()
  if not game:get_value"oakhaven_palace_rune_activated" then
    game:start_dialog("_oakhaven.observations.palace.secret_experiment_room.1", function(answer)
      if answer == 3 then
        glowing_rune:set_enabled(true)
        sol.audio.play_sound"charge_1"
        sol.audio.play_sound"sea_spirit"
        game:set_value("oakhaven_palace_rune_activated", true)
        game:set_value("quest_abyss", 2)
      end
    end)
  else
    game:start_dialog"_oakhaven.observations.palace.secret_experiment_room.afterglow"
  end
end

function im_in_palace_sensor:on_activated()
  if not game:get_value("found_path_from_abyss_to_oakhaven_palace") then
    game:start_dialog("_oakhaven.observations.palace.secret_experiment_room.2")
    game:set_value("found_path_from_abyss_to_oakhaven_palace", true)
  end
  im_in_palace_sensor:set_enabled(false)
end
