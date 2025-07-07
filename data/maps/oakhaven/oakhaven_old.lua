-- Lua script of map oakhaven/oakhaven.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()

local trumpet_player


map:register_event("on_started", function()
  if game:get_value("hazel_is_here") == true then cervio:set_enabled(false) end
  if game:get_value("salamander_heartache_storehouse_door_open") ~= nil then bar_storehouse_door:set_enabled(false) end
  if game:get_value("oakhaven_aubrey_unlocked") == true then
    aubrey_door_npc:set_enabled(false)
    aubrey_door:set_enabled(false)
  end
  --musicians sidequest:
  disguised_trumpet_player:set_traversable(true)
  if not game:get_value("oakhaven_find_poster_monster") then
    disguised_trumpet_player:set_enabled(false)
    for poster in map:get_entities("band_poster") do
      poster:set_enabled(false)
    end
  end
  if game:get_value("oakhaven_musicians_saved") == true then
    musician_1:set_enabled(false)
    musician_2:set_enabled(false)
  end
  --manna oak
  if game:get_value("quest_manna_oaks") and game:get_value("quest_manna_oaks") >= 7 then
    manna_tree_door:set_enabled(false)
  end
  if game:get_value("quest_manna_oaks") and game:get_value("quest_manna_oaks") >= 9 then
    hazel:set_enabled(true)
    manna_oak_leaves:set_enabled(true)
  end

  --spiked ale
  if not game:get_value("observed_spiked_ale_leaving") and game:get_value("spiked_crow_ale") then
    hero:freeze()
    barrel_carrier:set_enabled()
    watch_carrier_wall:set_enabled(true)
    local m = sol.movement.create("path")
    m:set_path{6,6,6,6,6,6,6,6,6,6,6,6,6,6}
    m:set_speed(70)
    m:start(barrel_carrier, function()
      game:start_dialog("_oakhaven.observations.saloon.see_booze_go")
      barrel_carrier:set_enabled(false)
      watch_carrier_wall:set_enabled(false)
      hero:unfreeze()
      game:set_value("observed_spiked_ale_leaving", true)
    end)
  end

end) --end of on_started


--NPCS---------------------

--GROVER
function grover:on_interaction()
  --looking for Hazel advice
  if game:get_value("grover_counter") == nil then
    game:start_dialog("_oakhaven.npcs.market.grover.1", function()
      game:set_value("quest_hazel", 2)  -- quest log, look at inn
      
      game:set_value("grover_counter", 1)
    end)
  --looking for mangrove thicket
  elseif game:get_value("quest_mangrove_sword") == 0 then
    game:start_dialog("_oakhaven.npcs.market.grover.3", function()
      game:set_value("quest_mangrove_sword", 1)
    end)
  --already spoken to
  elseif game:get_value("grover_counter") == 1 then
    game:start_dialog("_oakhaven.npcs.market.grover.2")
  --already found the thicket
  elseif game:get_value("quest_mangrove_sword") > 0 then
    game:start_dialog("_oakhaven.npcs.market.grover.4")
  end
end

--PALACE GUARD
function palace_guard:on_interaction()
  local _, hero_x, _ = hero:get_position()
  if hero:get_direction() == 0 then
    game:start_dialog("_oakhaven.npcs.guards.town.palace_displacement")
    palace_guard:get_sprite():set_direction(0)
    hero:teleport("oakhaven/oakhaven", "palace_ejection")

  else
    game:start_dialog("_oakhaven.npcs.guards.town.palace")
  end
end


--WISHING WELL
function wishing_well:on_interaction()
  if game:get_value("oakhaven_wishing_well_balance") == nil then game:set_value("oakhaven_wishing_well_balance", 0) end
  game:start_dialog("_oakhaven.npcs.misc.wishing_well.1", function(answer)
    if answer == 2 then
      --if you have enough money
      if game:get_money() >= 5 then
        game:remove_money(5)
        sol.audio.play_sound("splash")
        initial_money = game:get_value("oakhaven_wishing_well_balance")
        game:set_value("oakhaven_wishing_well_balance", initial_money + 5)

        --now check if that was enough money finally
        if initial_money == 195 then
          hero:start_treasure("coral_ore")
        end        
      --if you don't have enough money
      else
        game:start_dialog("_game.insufficient_funds")
      end
    end
  end)
end


--FRUIT IMPORTER
function fruit_importer:on_interaction()
  if game:get_value("oakhaven_fruit_importer_counter") == nil then
    game:start_dialog("_oakhaven.npcs.market.fruit_importer.1")

  --on the hunt for aubrey
  elseif game:get_value("oakhaven_fruit_importer_counter") == 1 then
    game:start_dialog("_oakhaven.npcs.market.fruit_importer.2", function()
      game:set_value("quest_tic_tac_toe", 4) --quest log
      game:set_value("oakhaven_have_oranges_box", true)
      game:set_value("possession_oranges_shipment", 1)
      game:set_value("oakhaven_fruit_importer_counter", 2)
    end)

  --have oranges, but not aubrey
  elseif game:get_value("oakhaven_fruit_importer_counter") == 2 then
    game:start_dialog("_oakhaven.npcs.market.fruit_importer.3")

  end
end


--Aubrey the Orange Thief
function aubrey_door_npc:on_interaction()
  --if you don't have the oranges yet
  if game:get_value("oakhaven_have_oranges_box") ~= true then
    game:start_dialog("_oakhaven.npcs.misc.aubrey_door")
  else
    game:start_dialog("_oakhaven.npcs.misc.aubrey_door_2", function()
      game:set_value("quest_tic_tac_toe", 5) --quest log
      aubrey_door_npc:set_enabled(false)
      aubrey_door:set_enabled(false)
      game:set_value("oakhaven_aubrey_unlocked", true)
    end)

  end
end


--Trumpet Player: Caught
function brian:on_interaction()

end


--Gunther
function musician_1:on_interaction()
  if game:get_value("gunther_counter")==nil then
    game:start_dialog("_oakhaven.npcs.musicians.gunther.1", function(answer)
      if answer == 2 then --let's help gunther!
        game:start_dialog("_oakhaven.npcs.musicians.gunther.2", function()
          game:set_value("quest_oakhaven_musicians", 0) --quest log
          game:set_value("oakhaven_band_talk_to_bartender", true)
          game:set_value("gunther_counter", 2)
        end)
      end
    end)

  --he's sent you to the bar
  elseif game:get_value("gunther_counter") == 2 then
    game:start_dialog("_oakhaven.npcs.musicians.gunther.3")

  elseif game:get_value("gunther_counter") ==3 then
    game:start_dialog("_oakhaven.npcs.musicians.gunther.4")

  elseif game:get_value("gunther_counter") == 4 then
    game:start_dialog("_oakhaven.npcs.musicians.gunther.5")
  end
end

function musician_2:on_interaction()
  game:start_dialog("_oakhaven.npcs.musicians.gloria.1")
end

for poster in map:get_entities("band_poster") do
  function poster:on_interaction()
    game:start_dialog("_oakhaven.observations.misc.poster")
  end
end


--HAZEL, post tree quest
function hazel:on_interaction()
  if game:get_value("quest_manna_oaks") == 9 then
    game:start_dialog("_oakhaven.npcs.hazel.tree.1", function()
      hero:start_treasure("elixer")           --IS AN ELIXER THE BEST REWARD?????
      game:set_value("quest_manna_oaks", 10)
    end)
  else
    game:start_dialog("_oakhaven.npcs.hazel.tree.2")
  end
end

---------------------------



--poster monster sensor
local monster_sensor_tripped = false
for sensor in map:get_entities("poster_monster_sensor") do
  function sensor:on_activated()
    if game:get_value("oakhaven_find_poster_monster") and monster_sensor_tripped == false then
      monster_sensor_tripped = true
      game:start_dialog("_oakhaven.observations.misc.poster_monster", function() 
        game:set_value("quest_oakhaven_musicians", 1) --quest log
        poster_monster_wall:set_enabled(false)
        game:set_value("poster_monster_caught", true)
        sensor:set_enabled(false)
      end)
    end
  end
end

--palace entry sensor
function palace_entry_sensor:on_activated()
  if not game:get_value("oakhaven_palace_party_permission_granted") then
    --don't have the invitation
    if not game:get_value("quest_mayors_dog") then
      game:start_dialog("_oakhaven.npcs.guards.town.party_entrance_no")
      hero:walk("666")
    else
      game:start_dialog("_oakhaven.npcs.guards.town.party_entrance_yes", function()
        game:set_value("quest_mayors_dog", 1)
        game:set_value("oakhaven_palace_party_permission_granted", true)
      end)
    end
  end
end




----------------------------


--intro cutscene
function remember_sensor:on_activated()
  if game:get_value("hazel_is_here") ~= true then
    game:start_dialog("_generic_dialogs.hey")
    hero:freeze()
    local m = sol.movement.create("path")
    m:set_path{0}
    m:start(hero)
    hero:set_direction(0)
    function m:on_finished()
      hero:unfreeze()
      game:start_dialog("_oakhaven.npcs.port.cervio.1", function()
--        sol.audio.play_sound("quest_log")
        
        game:set_value("quest_hazel", 1) --quest log
      end)
      game:set_value("quest_log_a", "a9")
      game:set_value("hazel_is_here", true)
    end
  end
end