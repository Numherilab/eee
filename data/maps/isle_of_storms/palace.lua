local map = ...
local game = map:get_game()
local camera = map:get_camera()

local map_width, map_height = map:get_size()
local particles = {}
local MAX_PARTICLES = 20
local PARTICLE_SPEED = 10

local white_surface


map:register_event("on_started", function()

--particle effect creation
  local i = 1
  sol.timer.start(map, math.random(50,100), function()
    local hx, hy, hz = hero:get_position()
    particles[i] = sol.sprite.create("entities/pollution_ash")
    particles[i]:set_xy(hx + math.random(-300, 300), hy + math.random(-300, 300))
    i = i + 1
    if i > MAX_PARTICLES then i = 1 end
    return true
  end)
  --particle movement
  --[[
  sol.timer.start(map, 1000/PARTICLE_SPEED, function()
    for _, particle in pairs(particles) do
      local x, y = particle:get_xy()
      particle:set_xy(x + math.random(-1, 1), y + math.random(-1, 1))
    end
    return true
  end)
  --]]

  map:set_doors_open("boss_door")

--disable entities once they've moved on
  if game:get_value("storm_palace_sea_king_tease_1") then
    sea_tease_1:set_enabled(false)
    teaser_king_1:set_enabled(false)
    dying_pirate_a_1:set_enabled(false)
    dying_pirate_a_2:set_enabled(false)
  end
  if game:get_value("storm_palace_sea_king_tease_2") then
    teaser_king_2:set_enabled(false)
    sea_tease_2:set_enabled(false)
    for enemy in map:get_entities("dying_pirate_b") do
      enemy:set_enabled(false)
    end
  end
  if game:get_value("storm_palace_mallow_cutscene") then
    mallow:set_enabled(false)
    blackbeard_mallow:set_enabled(false)
    see_mallow_sensor:set_enabled(false)
  end
  if game:get_value("sea_king_defeated") then
    sea_king_boss:set_enabled(false)
    boss_sensor:set_enabled(false)
    for entity in map:get_entities("palace_collapse_tile") do
      entity:set_enabled(true)
    end
    require("scripts/fx/sound_atmosphere_manager"):start_atmosphere(map, "rain")
    local world = map:get_world()
    game:set_world_rain_mode(world, "rain")
  end

end)


map:register_event("on_opening_transition_finished", function()
  if game:get_value("sea_king_defeated") then sol.audio.play_music("oceans_heart") end
--  white_surface:fade_out(100)
--  fog2:fade_in(100)
end)




---------------SWITCHES-----------------
function switch_c6:on_activated()
  sol.audio.play_sound("switch")
  map:focus_on(camera, switch_door_c6_4, function() map:open_doors("switch_door_c6") end)
end

function switch_d6:on_activated()
  sol.audio.play_sound("switch")
  map:focus_on(camera, switch_door_d6_5, function() map:open_doors("switch_door_d6") end)
end

local b4_timers = {}

function b4_switch_a:on_activated()
  for platform in map:get_entities("b4_platform_a") do
    platform:set_enabled(true)
    local x, y, l = platform:get_position()
    map:create_poof(x+16, y+16, l)
    local timer = sol.timer.start(map, 5000, function()
      platform:set_enabled(false)
      b4_switch_a:set_activated(false)
      map:create_poof(x+16, y+16, l)
    end)
    timer:set_with_sound(true)
    table.insert(b4_timers, timer)
  end
end

function b4_switch_b:on_activated()
  for platform in map:get_entities("b4_platform_b") do
    platform:set_enabled(true)
    local x, y, l = platform:get_position()
    map:create_poof(x+16, y+16, l)
    local timer = sol.timer.start(map, 5000, function()
      platform:set_enabled(false)
      b4_switch_b:set_activated(false)
      map:create_poof(x+16, y+16, l)
    end)
    timer:set_with_sound(true)
    table.insert(b4_timers, timer)
  end
end

function b4_switch_c:on_activated()
  for platform in map:get_entities("b4_platform_c") do
    platform:set_enabled(true)
    local x, y, l = platform:get_position()
    map:create_poof(x+16, y+16, l)
    local timer = sol.timer.start(map, 5000, function()
      platform:set_enabled(false)
      b4_switch_c:set_activated(false)
      map:create_poof(x+16, y+16, l)
    end)
    timer:set_with_sound(true)
    table.insert(b4_timers, timer)
  end
end

function b4_switch_d:on_activated()
  for platform in map:get_entities("b4_platform") do
    platform:set_enabled(true)
    local x, y, l = platform:get_position()
    map:create_poof(x+16, y+16, l)
  end
  for i = 1, #b4_timers do b4_timers[i]:stop() end
end

for switch in map:get_entities("b1_switch") do
  function switch:on_activated()
    local all_switches = true
    for s in map:get_entities("b1_switch") do
      if not s:is_activated() then all_switches = false end
    end
    if all_switches then
      for bridge in map:get_entities("b1_bridge") do bridge:set_enabled(true) end
      map:create_poof(680, 256, 0)
      map:get_camera():shake()
    end
  end
end

function entry_hub_center_switch:on_activated()
  map:focus_on(map:get_camera(), entry_room_central_door, function()
    map:open_doors("entry_room_central_door")
  end)
end

function switch_e_13:on_activated()
  map:open_doors("door_e_13")
end

function switch_e_12:on_activated()
  map:open_doors("door_e_12")
end

function a6_switch:on_activated()
  map:open_doors("door_a6")
end

function f6_switch:on_activated()
  map:focus_on(map:get_camera(), f6_door, function() map:open_doors("f6_door") end)
end

for switch in map:get_entities("f5_switch") do
  function switch:on_activated()
    local all_on = true
    for s in map:get_entities("f5_switch") do
      if not s:is_activated() then all_on = false end
    end
    if all_on then map:open_doors("f5_door") end
  end
end

function d3_switch_1:on_activated()
  map:focus_on(map:get_camera(), d3_door_1, function()
    map:open_doors("d3_door_1")
  end)
end

function d3_switch_2:on_activated()
  map:focus_on(map:get_camera(), d3_door_2, function()
    map:open_doors("d3_door_2")
  end)
end

function d3_switch_3:on_activated()
  map:focus_on(map:get_camera(), d3_door_3, function()
    map:open_doors("d3_door_3")
  end)
end



--------------SENSORS---------------------------
function teleport_to_surface_sensor:on_activated()
  hero:freeze()
  hero:set_direction(3)
  sol.audio.play_sound("sea_spirit")
  sol.audio.play_sound("charge_1")
  sol.audio.play_sound("warp")
  white_surface:fade_in(150, function()
    hero:teleport("isle_of_storms/isle_of_storms_landing", "from_palace_teleport")
  end)
end

for sensor in map:get_entities("block_reset_sensor") do
function sensor:on_activated()
  fourway_block:reset()
end
end

function boss_sensor:on_activated()
  boss_sensor:set_enabled(false)
  if not game:get_value("sea_king_defeated") then
    map:close_doors("boss_door")
    sol.audio.stop_music()
    sol.timer.start(map, 1500, function()
      sea_king_boss:set_enabled(true)
      map:create_poof(sea_king_boss:get_position())
      sol.audio.play_sound("fire_burst_3")
      sol.audio.play_sound("monster_scream")
      sol.audio.play_music("oceans_heart")
      sol.timer.start(map, 10000, function() sea_king_boss:unlock_pattern_attack() end)
    end)
  end
end

function squid_mage_unblocker_1:on_activated()
  unlock_squid_mage_1:set_enabled(false)
end

function squid_mage_unblocker_2:on_activated()
  unlock_squid_mage_2:set_enabled(false)
end

function squid_mage_unblocker_3:on_activated()
  unlock_squid_mage_3:set_enabled(false)
end

--sea king teaser 1
function sea_tease_1:on_activated()
  hero:freeze()
  teaser_king_1:create_sprite("enemies/misc/sea_beam")
  sol.audio.play_sound("beam")
  local m = sol.movement.create("straight")
  m:set_max_distance(128)
  m:set_speed(90)
  m:set_angle(0)
  m:start(teaser_king_1)
  function m:on_finished()
    map:create_poof(teaser_king_1:get_position())
    teaser_king_1:set_enabled(false)
  end
  sol.timer.start(map, 100, function()
    dying_pirate_a_1:create_sprite("enemies/enemy_killed")
    sol.timer.start(map, 100, function() dying_pirate_a_1:remove() sol.audio.play_sound("enemy_killed") end)
    hero:unfreeze()
  end)
  sol.timer.start(map, 100, function()
    dying_pirate_a_2:create_sprite("enemies/enemy_killed")
    sol.timer.start(map, 400, function() dying_pirate_a_2:remove() sol.audio.play_sound("enemy_killed") end)
  end)
  game:set_value("storm_palace_sea_king_tease_1", true)
  sea_tease_1:set_enabled(false)
end

--sea king teaser 2
function sea_tease_2:on_activated()
  sea_tease_2:set_enabled(false)
  sol.audio.play_sound("fire_burst_2")
  for enemy in map:get_entities("dying_pirate_b") do
    local x, y, layer = enemy:get_position()
    map:create_enemy{x=x,y=y+6,layer=layer+1,direction=0,breed="misc/sea_blast"}
    enemy:create_sprite("enemies/enemy_killed")
    sol.timer.start(map, 500, function() enemy:set_enabled(false) sol.audio.play_sound("enemy_killed") end)
  end
  sol.timer.start(map, 1000, function()
    map:create_poof(teaser_king_2:get_position())
    teaser_king_2:set_enabled(false)
    game:set_value("storm_palace_sea_king_tease_2", true)
  end)
end


--mallow_cutscene
function see_mallow_sensor:on_activated()
  see_mallow_sensor:set_enabled(false)
  hero:freeze()
  hero:walk("00000000000000000000")
  sol.timer.start(map, 1200, function()
    hero:freeze()
    game:start_dialog("_palace_of_storms.cutscenes.mallow.1", function()
      hero:freeze()
      local m=sol.movement.create("path") m:set_speed(60) m:set_path{4,4,4,4}
      m:start(mallow, function()
        game:start_dialog("_palace_of_storms.cutscenes.mallow.2", function()
          blackbeard_mallow:set_enabled(true)
          local m = sol.movement.create("path") m:set_path{4,4} m:set_ignore_obstacles() m:set_speed(60)
          m:start(blackbeard_mallow, function()
            game:start_dialog("_palace_of_storms.cutscenes.mallow.3", function()
              local bs = blackbeard_mallow:get_sprite()
              sol.audio.play_sound("hand_cannon")
              bs:set_animation("shoot", function()
                bs:set_animation("stopped")
                local mx,my,ml = mallow:get_position()
                map:create_explosion{x = mx + 16, y = my+4,layer=ml}
              end)
              sol.timer.start(map, 400, function()
                local ms = mallow:get_sprite()
                ms:set_animation("attacked")
                sol.timer.start(map, 200, function()
                  local m2=sol.movement.create("jump")
                  m2:set_direction8(4) m2:set_speed(100) m2:set_distance(16)
                  m2:start(mallow, function()
                    sol.timer.start(map, 10, function() ms:set_animation("attacked") end)
                    local m3 = sol.movement.create("path") m:set_speed(90)
                    m3:set_path{0,0,0,0,0,0,0,0,0,0}
                    m3:start(blackbeard_mallow, function() blackbeard_mallow:set_enabled(false) end)
                    ms:set_animation("attacked")
                    sol.timer.start(map, 1800, function() map:mallow_scene_continued() end)
                  end)
                end)
              end)
            end)
          end)
        end)
      end)
    end)
  end)
end

function map:mallow_scene_continued()
  game:start_dialog("_palace_of_storms.cutscenes.mallow.4", function()
    local ms = mallow:get_sprite()
    ms:set_direction(0)
    ms:set_animation("stopped")
    local m=sol.movement.create("path") m:set_speed(60)
    m:set_path{0,0,0,0,0}
    m:start(mallow, function()
      sol.timer.start(map, 10, function() ms:set_animation("collapsed") end)
      sol.timer.start(map, 1200, function()
        game:start_dialog("_palace_of_storms.cutscenes.mallow.4-2")
        local m2 = sol.movement.create"path"
        m2:set_path{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
        m2:set_ignore_obstacles()
        m2:start(mallow, function()
          mallow:set_enabled(false)
          hero:unfreeze()
          game:set_value("storm_palace_mallow_cutscene", true)
        end)
      end)
    end)
  end)
end




--------------ENEMIES-------------------------
function b_15_enemy:on_dead()
  map:open_doors("b15_door")
end

function d_15_enemy:on_dead()
  map:open_doors("d15_door")
end


for enemy in map:get_entities("f12_enemy") do
function enemy:on_dead()
  if not map:has_entities("f12_enemy") then
    map:focus_on(map:get_camera(), f12_door, function()
      map:open_doors("f12_door")
    end)
  end
end
end







--------------BOSS---------------------------
sea_king_boss:register_event("on_dead", function()
  sol.audio.stop_music()
  map:open_doors("boss_door")
  game:set_respawn_point()
  hero:freeze()
  hero:get_sprite():set_animation("floating")
  local m = sol.movement.create("target")
  m:set_target(boss_arena_center)
  m:start(hero, function()
    white_surface:fade_in(100, function()
      game:start_dialog("_palace_of_storms.cutscenes.sea_king.1", function()
        sol.timer.start(map, 100, function() game:start_dialog("_palace_of_storms.cutscenes.sea_king.2") end)
        hero:set_animation("laying_down")
        sneaky_blackbeard:set_enabled(true) 
        sneaky_blackbeard:get_sprite():set_animation("holding_oceans_heart")
        white_surface:fade_out(100, function()
          hero:set_animation("waking_up", function()
            hero:set_animation"stopped"
            game:start_dialog("_palace_of_storms.cutscenes.sea_king.3", function()
              sol.audio.play_music("oceans_heart")
              game:set_value("sea_king_defeated", true)
              game:set_value("quest_isle_of_storms", 3)
              map:building_collapse()
              hero:unfreeze()
            end)
          end)
        end)
      end)
    end)
  end)
end)


function map:building_collapse()
  for e in map:get_entities"blackbeard_magic_blocker" do
    e:set_enabled(true)
  end
  for entity in map:get_entities("palace_collapse_tile") do
    entity:set_enabled(true)
  end
  require("scripts/fx/sound_atmosphere_manager"):start_atmosphere(map, "rain")
  local world = map:get_world()
  game:set_world_rain_mode(world, "rain")

  local i = 1
  --targeted rocks
  sol.timer.start(map, 1000, function()
      local x, y, l = hero:get_position()
      map:create_falling_rock(x, y, l)
      if i < math.random(3, 6) then
        i = i + 1
        return math.random(1000, 2500)
      else
        i = 1
        return math.random(4000, 5000)
      end
  end)
  --general rocks
  sol.timer.start(map, 200, function()
    local x, y, l = hero:get_position()
    x = x + math.random(-200, 200)
    y = y + math.random(-100, 100)
    map:create_falling_rock(x, y, l)
    return math.random(200, 1000)
  end)

end

function map:create_falling_rock(x, y, l)
  local rock = map:create_enemy{
    direction = 0, layer = l, x = x + math.random(-16, 16), y = y + math.random(-16, 16),
    breed = "misc/falling_rock"
  }
  rock:set_shake_props(2,2,100)
end


for e in map:get_entities("blackbeard_magic_blocker") do
  function e:on_interaction()
    sol.audio.play_sound"cane"
  end
end





---------------FOG--------------
white_surface = sol.surface.create()
  white_surface:fill_color({255,255,255})
  white_surface:set_opacity(0)
local camera_surface = map:get_camera():get_surface()

local fog = sol.surface.create("fog/big_water_light.png")
fog:set_blend_mode("blend")
fog:set_opacity(25)
local fog2 = sol.surface.create("fog/big_water_dark.png")
fog2:set_blend_mode("multiply")
fog2:set_opacity(25)
fog2:set_xy(-500,-150)
local fog3 = sol.surface.create("fog/water_squiggles.png")
fog3:set_blend_mode("blend")
fog3:set_opacity(30)
fog3:set_xy(-400,-270)
  function move_fog(fog, angle, distance)
    local m = sol.movement.create("straight")
    m:set_angle(angle)
    m:set_speed(20)
    m:set_max_distance(distance)
    m:start(fog, function() move_fog(fog, angle + math.pi, distance) end)
  end
move_fog(fog, 3, 180)
move_fog(fog2, .3, 270)
move_fog(fog3, -2.2, 220)

function map:on_draw(dst_surface)
    for i=1, #particles do
      map:draw_visual(particles[i], 0, 0)
    end

  local cam_surface = map:get_camera():get_surface()
  white_surface:draw(dst_surface)
  fog:draw(cam_surface)
  fog2:draw(cam_surface)
  fog3:draw(cam_surface)
end

