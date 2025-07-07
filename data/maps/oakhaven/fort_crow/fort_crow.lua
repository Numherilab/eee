-- Lua script of map oakhaven/fort_crow/fort_crow.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local need_to_be_insibible = false --wtf is this variable?
local hero = map:get_hero()

map:register_event("on_started", function()
  map:set_doors_open("boss_door")
  if game:get_value("quest_snapmast") then jazari_dummy:set_enabled(false) end
  morus_4:get_sprite():set_animation("unconscious")
  if not game:get_value("fort_crow_miniboss_defeated") then miniboss:set_enabled(true)
  else map:set_doors_open("b3_door")
  end
  if game:get_value("fort_crow_interior_morus_counter") == 1 then morus_1:set_enabled(true) end
  if game:get_value("fort_crow_interior_morus_counter") == 2 then morus_2:set_enabled(true) end
  if game:get_value("fort_crow_interior_morus_counter") == 3 then morus_3:set_enabled(true) end
  if game:get_value("fort_crow_interior_morus_counter") == 4 then morus_4:set_enabled(true) end
  if game:get_value"jazari_defeated" then
    boss_sensor:set_enabled(false)
    jazari_dummy:get_sprite():set_animation("unconscious")
  end

  --Alternating Steam Timer
  --Set half the steam initially disabled
  for steam in map:get_entities("alternating_steam_b") do steam:set_enabled(false) end
  sol.timer.start(map, 4000, function()
    sol.audio.play_sound("click_low")
    for steam in map:get_entities("alternating_steam") do
      steam:set_enabled(not steam:is_enabled())
    end
    return true
  end)

  --Robot Part Spawners
  for spawner in map:get_entities("robot_part_spawner") do
    local x, y, layer = spawner:get_position()
    sol.timer.start(map, 2000, function() map:spawn_robot_part(x, y, layer, 0) return true end)
  end

end)



------Switches---------
function f5_switch:on_activated()
  map:open_doors("f5_door")
end

for switch in map:get_entities("a6_switch") do
function switch:on_activated()
  sol.audio.play_sound("switch")
  sol.audio.play_sound("steam_01")
  for steam in map:get_entities("a6_steam") do
    if steam:is_enabled() then steam:set_enabled(false)
    else steam:set_enabled(true) end
  end
  sol.timer.start(map, 200, function() switch:set_activated(false) end)
end
end

function e4_switch_a:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("e4_door_b")
end

function e4_switch_a:on_inactivated()
  sol.audio.play_sound("switch")
  map:close_doors("e4_door_b")
end

function e4_switch_b:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("e4_door_a")
end

function b4_switch:on_activated()
  sol.audio.play_sound("switch")
  map:focus_on(map:get_camera(), a4_door, function() map:open_doors("a4_door") end)
end

function e1_switch:on_activated() --opens boss door
  sol.audio.play_sound("switch")
  map:open_doors("e1_door")
  game:start_dialog("_oakhaven.npcs.morus.fort.5", function()
    local m = sol.movement.create("path")
    m:set_path{2,2,2,2,2,2,2,2}
    m:start(morus_3, function() morus_3:set_enabled(false) end)
    game:set_value("fort_crow_interior_morus_counter", 4)
    morus_4:set_enabled(true)
  end)
end

function d1_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("d1_door")
end

--pre-miniboss switch
function f3_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("c4_door")
  game:start_dialog("_oakhaven.npcs.morus.fort.4")
  morus_2:set_enabled(false)
  morus_3:set_enabled(true)
  game:set_value("fort_crow_interior_morus_counter", 3)
end



-----Sensors----------
--[[function boss_sensor:on_activated()
  game:start_dialog("_oakhaven.npcs.fort_crow.jazari.2", function()
    jazari_dummy:set_enabled(false)
    jazari_boss:set_enabled(true)
  end)
end
--]]


-----Enemies-----------
for enemy in map:get_entities("a5_enemy") do
  function enemy:on_dead()
    if not map:has_entities("a5_enemy") then
      sol.audio.play_sound("secret")
      map:open_doors("a5_door")
    end
  end
end

function miniboss:on_dead()
  map:open_doors("b3_door")
end



-------Robot Parts------------
function map:spawn_robot_part(x, y, layer, direction)
  local bot_part = map:create_stream({
    x = x+8, y = y+11, layer = layer, direction = direction,
    sprite = "entities/robot_parts", speed = 96,
  })
  bot_part:set_drawn_in_y_order(true)
  local m = sol.movement.create("straight")
  m:set_angle(direction * math.pi / 2)
  m:start(bot_part, function() bot_part:remove() end)
  function m:on_obstacle_reached() bot_part:remove() end
end



--------Morus'es------------
function morus_1:on_interaction()
  game:start_dialog("_oakhaven.npcs.morus.fort.2", function()
    local m = sol.movement.create("path")
    m:set_speed(80)
    m:set_path{2,2,2,2,2,2,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2}
    m:start(morus_1, function() morus_1:remove() end)
    game:set_value("fort_crow_interior_morus_counter", 2)
    morus_2:set_enabled(true)
  end)
end


------BOSSSSS------------------
function boss_sensor:on_activated()
  boss_sensor:set_enabled(false)
  hero:freeze()
  local m = sol.movement.create("path")
  m:set_path{2,2,2,2,2,2,2,2}
  m:set_speed(90)
  m:start(hero, function()
    game:start_dialog("_oakhaven.npcs.fort_crow.jazari.2", function()
      hero:unfreeze()
      sol.audio.play_music"boss_battle"
      map:close_doors"boss_door"
      jazari_dummy:set_enabled(false)
      jazari_boss:set_enabled(true)
    end)
  end)
end

local jazari_x, jazari_y, jazari_l
function jazari_boss:on_dying()
  jazari_x, jazari_y, jazari_l = jazari_boss:get_position()
  jazari_boss:stop_movement()
  for grate in map:get_entities("fire_grate_boss_room") do
    grate:set_turned_off(true)
  end
end

function jazari_boss:on_dead()
  game:set_value("jazari_defeated", true)
  if not game:get_value("quest_snapmast") then
    map:fade_in_music()
    hero:freeze()
    map:open_doors("boss_door")
    jazari_dummy:set_enabled(true)
    jazari_dummy:set_position(jazari_x, jazari_y, jazari_l)
    jazari_dummy:get_sprite():set_animation("unconscious")
    local hx, hy = hero:get_position()
    local jx, jy = jazari_dummy:get_position()
    local too_close = (math.abs(hx - jx) < 24) or (math.abs(hy - jy) < 24)
print("OVERLAP CHECK", hero:overlaps(jazari_dummy))
print("TOO CLOSE CHECK", too_close)
    if hero:overlaps(jazari_dummy) or too_close then
      local angle = hero:get_angle(fire_grate_boss_room_78)
      local m = sol.movement.create"straight"
      m:set_max_distance(24)
      m:set_ignore_obstacles(true)
      m:set_angle(angle)
      m:set_speed(150)
      m:start(hero)
    end
    sol.timer.start(map, 800, function()
      morus_4:get_sprite():set_animation("stopped")
      sol.timer.start(map, 400, function()
        game:start_dialog("_oakhaven.npcs.morus.fort.6", function() hero:unfreeze() end)
      end)
    end)
  end
end


------------------------Post Boss-------
function chart_npc:on_interaction()
  if game:has_item("hideout_chart") ~= true then
  hideout_chart:set_enabled(false)
  hero:start_treasure("fast_travel_chart_snapmast", 1, "found_snapmast_reef_hideout_map", function()
    game:set_value("quest_log_b", "b10")
    game:set_value("quest_pirate_fort", 6) --quest log, take chart to morus
    game:set_value("morus_counter", 5)
    hero:freeze()
    morus_5:set_enabled(true)
    local m = sol.movement.create("path")
    m:set_path{4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4}
    m:set_speed(70)
    m:start(morus_5, function()
      game:start_dialog("_oakhaven.npcs.morus.fort.8", function(answer)
        hero:unfreeze()
        game:set_value("fort_crow_interior_morus_counter", 6)
        game:set_value("quest_pirate_fort", 7) --quest log, pirate fort complete
        game:set_value("quest_snapmast", 0) --start snapmast quest
        game:set_value("quest_log_b", "b11")
        game:set_value("morus_counter", 6)
        game:set_value("morus_available", false)
        game:set_value("morus_at_port", true)
        if answer == 2 then --right to port
          hero:teleport("oakhaven/port", "fast_travel_destination", "fade")
        else
          game:start_dialog("_oakhaven.npcs.morus.fort.9", function()
            hero:teleport("stonefell_crossroads/fort_crow", "from_fort_crow_front_door", "fade")
          end)
        end
      end)
    end)
    
  end)
  end
end


