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
  game:set_world_fall_mode(map:get_world(), "fall")
  map:initialize_npc_movements()

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

end) --end of on_started

--intro cutscene
function remember_sensor:on_activated()
  if game:get_value("hazel_is_here") ~= true then
    game:start_dialog("_generic_dialogs.hey")
    hero:freeze()
    hero:walk("2222210")
    sol.timer.start(map, 800, function()
      hero:unfreeze()
      game:start_dialog("_oakhaven.npcs.port.cervio.1", function()
        game:set_value("quest_hazel", 1) --quest log
        game:set_value("quest_log_a", "a9")
        game:set_value("hazel_is_here", true)
      end)
    end)
  end
end


-------------------------NPCS----------------------------
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

--Barty, weather guy
function barty:on_interaction()
  local i = math.random(1,3)
  game:start_dialog("_oakhaven.npcs.general_town.barty." .. i)
end


---Shops:
function blacksmith:on_interaction()
  require("scripts/shops/blacksmith"):open_shop(game)
end


function ferris:on_interaction()
  --if you haven't increased armor yet
  if game:get_value("ferris_armor_counter") == nil then

    game:start_dialog("_oakhaven.npcs.blacksmith.ferris.1", function(answer)
      if answer == 2 then
        if game:get_money() >= 100 then
          game:remove_money(100)
          game:start_dialog("_oakhaven.npcs.blacksmith.ferris.upgrade_armor")
          game:set_value("defense", game:get_value("defense") + 1)
          game:set_value("ferris_armor_counter", 1)
        else
          game:start_dialog("_game.insufficient_funds")
        end
      end
    end) --end of dialog callback

  --if you've done one increase
  elseif game:get_value("ferris_armor_counter") == 1 then
    
    --if you do not have tools
    -- print(game:has_item("armor_tools"))
    if not game:has_item("armor_tools") then
      game:start_dialog("_oakhaven.npcs.blacksmith.ferris.2", function()
        game:set_value("quest_ferris_tools", 0) --quest log
      end)
    --if you HAVE the tools
    else
      game:start_dialog("_oakhaven.npcs.blacksmith.ferris.3", function(answer)
        game:set_value("quest_ferris_tools", 2) --quest log
        if answer == 2 then
          game:start_dialog("_oakhaven.npcs.blacksmith.ferris.upgrade_armor_2")
          game:set_value("defense", game:get_value("defense") + 2)
          game:set_value("ferris_armor_counter", 2)
        end
      end) --end of dialoge callback
    end
  elseif game:get_value("ferris_armor_counter") == 2 then
    game:start_dialog("_oakhaven.npcs.blacksmith.ferris.4")
  end --end of ferris_armor_counter
end



----------------------------SENSORS---------------------
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

--spiked ale
function watch_barrel_carrier_sensor:on_activated()
  if not game:get_value("observed_spiked_ale_leaving") and game:get_value("spiked_crow_ale") then
    hero:freeze()
    barrel_carrier:set_enabled()
    map:focus_on(map:get_camera(), barrel_carrier, function()
    local m = sol.movement.create("path")
    m:set_path{6,6,6,6,6,6,6,6,6,6,6,6,6,6}
    m:set_speed(60)
    m:start(barrel_carrier, function()
      game:start_dialog("_oakhaven.observations.saloon.see_booze_go")
      barrel_carrier:set_enabled(false)
      hero:unfreeze()
      game:set_value("observed_spiked_ale_leaving", true)
    end)
    end)

  end
end

------------------------OTHER ENTITIES--------------------------------------------

--haunted house door
function haunted_house_door:on_opened()
  game:set_value("quest_oakhaven_haunted_key", 1)
end



------------------------WALKING AROUND NPCS--------------------------------------
local TOTAL_WAYPOINTS = 56

function map:initialize_npc_movements()
  for npc in map:get_entities("random_walk") do
    local m = sol.movement.create("random_path")
    if npc:get_property("speed") then m:set_speed(npc:get_property("speed")) end
    m:start(npc)
  end

  --there are 56 waypoints
  for npc in map:get_entities("looping_walker") do
    --set a random walking speed
    npc.speed = math.random(25, 45)
    --find closest waypoint
    local starting_waypoint = loop_waypoint_1
    for point in map:get_entities("loop_waypoint") do
      if npc:get_distance(point) < npc:get_distance(starting_waypoint) then starting_waypoint = point end
    end
    --go over there
    local m = sol.movement.create("target")
    m:set_target(starting_waypoint)
    m:set_speed(npc.speed)
    m:start(npc, function()
    local current_waypoint_num = string.match(starting_waypoint:get_name(), "%d+")
    local next_waypoint_num = (current_waypoint_num + (npc:get_property("loop_backwards_value") or 1)) % TOTAL_WAYPOINTS
    map:advance_waypoints(npc, next_waypoint_num)
    end)
  end
end --end initialize NPC movements

function map:advance_waypoints(npc, waypoint_no)
--print("seeking waypoint " .. waypoint_no)
  local m = sol.movement.create("target")
  m:set_speed(npc.speed)
  m:set_ignore_obstacles()
  m:set_target(map:get_entity("loop_waypoint_" .. waypoint_no))
  local next_waypoint_no = (waypoint_no + (npc:get_property("loop_backwards_value") or 1)) % TOTAL_WAYPOINTS
  m:start(npc, function() map:advance_waypoints(npc, next_waypoint_no) end)
end