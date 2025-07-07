local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  if game:get_value("salamander_heartache_storehouse_door_open") == true then map:open_doors("storehouse_door") end
  if game:has_item("sleeping_draught") == true then star_barrel:set_enabled(true) end
  if game:get_value("morus_available") ~= true then morus:set_enabled(false) end
  if game:get_value("oakhaven_musicians_saved") == true then
    brian:set_enabled(false)
  else
    musician_1:set_enabled(false)
    musician_2:set_enabled(false)
    for npc in map:get_entities"flaketron" do npc:set_enabled(false) end
  end
  if game:get_value"salamander_heartache_saloon_bombable_door_state" then
    associated_wall:remove()
  end
end)


--------------------------------------------------------------
-------------------NPCS---------------------------------------

function patron_1:on_interaction()
  if game:get_value("oakhaven_musicians_saved") ~= true then
    game:start_dialog("_oakhaven.npcs.saloon.trumpet_era.1")
  else
    game:start_dialog("_oakhaven.npcs.saloon.gunther_band.1")
  end
end

function patron_2:on_interaction()
  if game:get_value("oakhaven_musicians_saved") ~= true then
    game:start_dialog("_oakhaven.npcs.saloon.trumpet_era.2")
  else
    game:start_dialog("_oakhaven.npcs.saloon.gunther_band.2")
  end
end


--BARTENDER----------

function bartender:on_interaction()
  --if you're on the gunther band quest
  if game:get_value("oakhaven_band_talk_to_bartender") == true
  and game:get_value("oakhaven_talked_to_bartender_about_monster") ~= true then
    game:start_dialog("_oakhaven.npcs.saloon.bartender_posters", function()
      game:set_value("quest_oakhaven_musicians", 1) --quest log
      game:set_value("oakhaven_find_poster_monster", true)
      game:set_value("oakhaven_talked_to_bartender_about_monster", true)
      game:set_value("gunther_counter", 3)
    end)

  --if you're looking for Morus
  elseif game:get_value("morus_available") == true then
    if game:get_value("morus_counter") == nil then game:start_dialog("_oakhaven.npcs.saloon.bartender1")
    else game:start_dialog("_oakhaven.npcs.saloon.bartender2")
    end

  else --if Morus isn't around yet.
    game:start_dialog("_oakhaven.npcs.saloon.bartender2")
  end
end



--MORUS----------

function morus:on_interaction()
  if game:get_value("morus_counter") == nil then
    game:start_dialog("_oakhaven.npcs.morus.1", function()

      game:set_value("quest_log_b", "b5")
      game:set_value("looking_for_sleeping_potion", true)
      game:set_value("quest_pirate_fort", 1) --quest log, go find sleeping potion
    end)
    game:set_value("morus_counter", 1)

  elseif game:get_value("morus_counter") == 1 then
    game:start_dialog("_oakhaven.npcs.morus.2")

  elseif game:get_value("morus_counter") == 2 then
    game:start_dialog("_oakhaven.npcs.morus.3-spike_ale", function()
      game:set_value("quest_log_b", "b8")

      game:set_value("quest_pirate_fort", 3) --quest log, go spike ale
      game:set_value("morus_counter", 3)
    end)

  elseif game:get_value("morus_counter") == 3 then
    game:start_dialog("_oakhaven.npcs.morus.4")

  elseif game:get_value("morus_counter") == 4 then
    game:start_dialog("_oakhaven.npcs.morus.5-gotofort")

  elseif game:get_value("morus_counter") == 5 then
    game:start_dialog("_oakhaven.npcs.morus.6", function()

      game:set_value("quest_pirate_fort", 7) --quest log, pirate fort complete
      game:set_value("quest_snapmast", 0) --start snapmast quest
      game:set_value("quest_log_b", "b11")
      game:set_value("morus_counter", 6)
      game:set_value("morus_available", false)
      game:set_value("morus_at_port", true)
    end)

  elseif game:get_value("morus_counter") == 6 then
    game:start_dialog("_oakhaven.npcs.morus.7")

  end
end


---GUNTHER--------------
function musician_1:on_interaction()
  if game:get_value("gunther_counter") ~= 5 then
    game:start_dialog("_oakhaven.npcs.musicians.gunther.6", function()
      game:set_value("quest_oakhaven_musicians", 4) --quest log
      game:get_hero():start_treasure("coral_ore")
      game:set_value("gunther_counter", 5)
    end) --end dialog callback
  else
    game:start_dialog("_oakhaven.npcs.musicians.gunther.7")
  end
end



--------------RANDOM BAR NPCS-------------------------------------

function weak_wall_clue_guy:on_interaction()
  if game:get_value"salamander_heartache_saloon_bombable_door_state" then
    game:start_dialog("_oakhaven.npcs.saloon.weak_wall_guy.2")
  else
    game:start_dialog("_oakhaven.npcs.saloon.weak_wall_guy.1")
  end

end




------------INANIMATE OBJECTS-------------------------------------

function weak_wall_door:on_opened()
  associated_wall:remove()
end

function storehouse_door_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("storehouse_door")
  game:set_value("salamander_heartache_storehouse_door_open", true)
end

function star_barrel_2:on_interaction()
  if game:get_value("morus_counter") == 3 then
    game:start_dialog("_oakhaven.observations.saloon.star_barrel_1", function(answer)
      if answer == 1 then
        game:start_dialog("_oakhaven.observations.saloon.star_barrel_2", function()

          game:set_value("quest_pirate_fort", 4) --quest log update, go sneak in now
          game:set_value("quest_log_b", "b9")
          game:set_value("morus_counter", 4)
          game:set_value("spiked_crow_ale", true)
        end)--end of dialog 2 function end--end of if answer is 1
      end --end of if answer is
    end)--end of dialog 1 function
  end
end
