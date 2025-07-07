local map = ...
local game = map:get_game()
local hero = game:get_hero()

map:register_event("on_started", function()
  map:get_camera():letterbox()
  if game:has_item("hideout_chart") == true then
  hideout_chart:set_enabled(false)
  end
  thyme_boss:set_enabled(false)
  if game:get_value("thyme_defeated") then thyme_npc:set_enabled(false) end
  map:set_doors_open("boss_door")
  for steam in map:get_entities("switch_a_steam") do steam:set_enabled(false) end
  if switch_a:is_activated() == true then
    for steam in map:get_entities("switch_a_steam") do steam:set_enabled(true) end
  end
  if game:get_value("fort_crow_tower_int_door_opened") == true then map:set_doors_open("door_d") end

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

function switch_a:on_activated()
  sol.audio.play_sound("steam_01")
  for steam in map:get_entities("switch_a_steam") do steam:set_enabled(true) end
  map:open_doors("door_a")
  sol.audio.play_sound("switch_2")
end

function switch_b:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("door_b")
end

function switch_c:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("door_c")
end

function switch_d:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("door_d")
  game:set_value("fort_crow_tower_int_door_opened", true)
end


function boss_sensor:on_activated()
  map:close_doors("boss_door")
  game:start_dialog("_oakhaven.npcs.fort_crow.thyme.1", function()
    thyme_npc:set_enabled(false)
    thyme_boss:set_enabled(true)
    map:create_enemy({name = "crow_xxl", x = 480, y = 200, layer = 0, direction = 3, breed = "normal_enemies/crow_xxl", })
  end)--end of dialog callback
--456, 352 (thyme location)
  boss_sensor:set_enabled(false)
end

local boss_x local boss_y local boss_layer
function thyme_boss:on_dying()
  boss_x, boss_y, boss_layer = thyme_boss:get_position()
end
function thyme_boss:on_dead()
  if map:has_entity("crow_xxl") then crow_xxl:hurt(1000) end
  map:open_doors("boss_door")
  game:set_value("thyme_defeated", true)

end

function chart_npc:on_interaction()
  if game:has_item("hideout_chart") ~= true then
  hideout_chart:set_enabled(false)
  hero:start_treasure("hideout_chart", 1, "found_snapmast_reef_hideout_map", function()
    game:set_value("quest_log_b", "b10")
    game:set_value("quest_pirate_fort", 6) --quest log, take chart to morus
    game:set_value("morus_counter", 5)
    hero:teleport("oakhaven/eastoak", "from_fort_crow_front_door", "fade")
  end)
  end
end
