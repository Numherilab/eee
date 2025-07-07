local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  map:get_camera():letterbox()
  al_jazari:set_enabled(false)
  for entity in map:get_entities("switchsteam_b") do entity:set_enabled(false) end
  if game:get_value("fort_crow_furnace_door_a") == true then map:set_doors_open("door_a") end
  if game:get_value("fort_crow_furnace_bridge_a") == true then bridge_a:set_enabled(true) end
  if game:get_value("fort_crow_furnace_area_door_b_opened") == true then map:set_doors_open("door_b") end
  if game:get_value("fort_crow_furnace_r") == true then
    for entity in map:get_entities("furnace_r") do entity:set_enabled(true) end end
  if game:get_value("fort_crow_furnace_l") == true then
    for entity in map:get_entities("furnace_l") do entity:set_enabled(true) end end
  if game:get_value("fort_crow_furnace_lit") == true then furnace_c:set_enabled(true) end
  if game:get_value("defeated_al_jazari") == true then boss_sensor:set_enabled(false) dummy_boss:set_enabled(false) end
  map:set_doors_open("boss_door")

--steam timer
  for steam in map:get_entities("steam_b") do steam:set_enabled(false) end

  sol.timer.start(map, 4000, function()
    sol.audio.play_sound("switch_3")
    sol.audio.play_sound("steam_01")
    for steam in map:get_entities("steam") do
      if steam:is_enabled() == true then steam:set_enabled(false)
      else steam:set_enabled(true)
      end
    end
    return true
  end) --end of 4 sec timer a.

end)


--save/reset solid ground sensors
for sensor in map:get_entities("ssg_sensor") do
function sensor:on_activated() hero:save_solid_ground() end
end

for sensor in map:get_entities("rsg_sensor") do
function sensor:on_activated() hero:reset_solid_ground() end
end




function door_a_switch:on_activated()
  map:open_doors("door_a")
  sol.audio.play_sound("switch")
  game:set_value("fort_crow_furnace_door_a", true)
end

function bridge_a_switch:on_activated()
  bridge_a:set_enabled(true)
  game:set_value("fort_crow_furnace_bridge_a", true)
end

function knight_barricade_sensor:on_activated()
  knight_barricade:set_enabled(false)
end

function switchsteam_switch:on_activated()
  for entity in map:get_entities("switchsteam_a") do entity:set_enabled(false) end
  for entity in map:get_entities("switchsteam_b") do entity:set_enabled(true) end
end

function switchsteam_switch:on_activated()
  for entity in map:get_entities("switchsteam_a") do entity:set_enabled(false) end
  for entity in map:get_entities("switchsteam_b") do entity:set_enabled(true) end
end
function switchsteam_switch:on_inactivated()
  for entity in map:get_entities("switchsteam_b") do entity:set_enabled(false) end
  for entity in map:get_entities("switchsteam_a") do entity:set_enabled(true) end
end

function door_b_switch:on_activated()
  map:open_doors("door_")
  game:set_value("fort_crow_furnace_area_door_b_opened", true)
end


--furnace_switches
function switch_furnace_r:on_activated()
  sol.audio.play_sound("switch")
  for entity in map:get_entities("furnace_r") do entity:set_enabled(true) end
  game:set_value("fort_crow_furnace_r", true)
  if game:get_value("fort_crow_furnace_l") == true then
    sol.audio.play_sound("switch_2")
    sol.audio.play_sound("secret")
    furnace_c:set_enabled(true)
    game:set_value("fort_crow_furnace_lit", true)
    game:start_dialog("_oakhaven.observations.fort_crow.opening_door")
  end
end
function switch_furnace_l:on_activated()
  sol.audio.play_sound("switch")
  for entity in map:get_entities("furnace_l") do entity:set_enabled(true) end
  game:set_value("fort_crow_furnace_l", true)
  if game:get_value("fort_crow_furnace_r") == true then
    sol.audio.play_sound("switch_2")
    sol.audio.play_sound("secret")
    furnace_c:set_enabled(true)
    game:set_value("fort_crow_furnace_lit", true)
    game:start_dialog("_oakhaven.observations.fort_crow.opening_door")
  end
end


--boss
local fighting_jazari
local function summon_automatons()
    map:create_enemy({
      name = "boss_spawn_crab",
      layer = 0, x = 240, y = 40,
      direction = 3,
      breed = "normal_enemies/automatic_crow_knight",
    })
    if fighting_jizari == true then
      sol.timer.start(10000, function() summon_automatons() end)
    end
end

function boss_sensor:on_activated()
  game:start_dialog("_oakhaven.npcs.fort_crow.jazari.1", function()
    dummy_boss:set_enabled(false)
    al_jazari:set_enabled(true)
  end)
  map:close_doors("boss_door")
  boss_sensor:set_enabled(false)
  jazari_barricade:set_enabled(false)
  fighting_jazari = true
  sol.timer.start(20000, function()
    if fighting_jazari == true then
    map:create_enemy({
      name = "boss_spawn_crow",
      layer = 0, x = 240, y = 40,
      direction = 3,
      breed = "normal_enemies/crowbot",
    })
    end --end of if fighting
  end)--end of timer function
  sol.timer.start(40000, function()
    if fighting_jazari == true then
    map:create_enemy({
      name = "boss_spawn_crow",
      layer = 0, x = 80, y = 40,
      direction = 3,
      breed = "normal_enemies/crowbot",
    })
    end --end of if fighting
  end)--end of timer function
end


function al_jazari:on_dying()
  fighting_jazari = false
  for entity in map:get_entities("boss_spawn") do entity:hurt(100) end
end

function al_jazari:on_dead()
  game:set_value("defeated_al_jazari", true)
  map:open_doors("boss_door")
end
