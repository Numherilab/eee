local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
enemy.immobilize_immunity = true
local sprite
local smoke_sprite
local beam_sprite
local angle = 0
local FULL_HEALTH = 400

local attacking = false
local puddling = false
--local can_throw_sword = true
local can_summon_hands = true
--local can_surround_attack = true
--local can_tide_attack = true
local can_pattern_attack = true
local can_quake = true
local can_summon_helpers = true

local can_pollute_blast = true
--local can_gross_dash = true
local can_teleport_shot = true
local can_skeleton_hands = true
local can_radial_attack = true
local can_rune_barrage = true
--local can_summon_crystals = true

local sweeping

-- Event called when the enemy is initialized.
function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  ring_sprite = enemy:create_sprite("enemies/bosses/abyss_beast_ring")
  ring_sprite:set_blend_mode("blend")
  enemy:bring_sprite_to_back(ring_sprite)
  enemy:set_invincible_sprite(ring_sprite)
  smoke_sprite = enemy:create_sprite("enemies/ghost_smoke_large")
  smoke_sprite:set_blend_mode("blend")
  enemy:bring_sprite_to_back(smoke_sprite)
  enemy:set_invincible_sprite(smoke_sprite) --]]
  faces_sprite = enemy:create_sprite("enemies/bosses/abyss_beast_faces")

  enemy:set_life(400)
  enemy:set_damage(30)
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_hurt_style("boss")

  enemy:set_attacking_collision_mode("overlapping")
  enemy:set_size(32,32)
end

function enemy:follow_hero()
  local m = sol.movement.create("target")
  m:set_speed(50)
  m:start(enemy)
end

function enemy:on_restarted()
  enemy:follow_hero()
  if sweeping then
    sweeping = false
    enemy:finish_attacking()
  end
  if enemy.teleport_shotting then
    enemy.teleport_shotting = false
    enemy:finish_attacking()
  end
  if enemy:get_sprite("sea_beam") then enemy:remove_sprite(enemy:get_sprite("sea_beam")) end
  sol.timer.start(enemy, 100, function()
    if enemy:get_life() > 1 then
      enemy:check_to_attack()
    end
    return true
  end)
end


function enemy:finish_attacking()
  sol.timer.start(map, 500, function()
    attacking = false
    enemy:on_restarted()
--print("finished attack")
  end)
end

function enemy:teleport_to(x,y,l)
  local a,b,c = enemy:get_position()
  sol.audio.play_sound"charge_warp"
  map:create_custom_entity{
    x=a,y=b+5,layer=c,direction=0,width=16,height=16,
    model="ephemeral_effect",sprite="enemies/bosses/abyss_beast_teleport_flash"
  }
  enemy:set_position(x,y,l)
  a,b,c = enemy:get_position()
  map:create_custom_entity{
    x=a,y=b+5,layer=c,direction=0,width=16,height=16,
    model="ephemeral_effect",sprite="enemies/bosses/abyss_beast_teleport_flash"
  }
end

--Select an Attack:
function enemy:check_to_attack()
  if not attacking then
    if can_radial_attack then
      attacking = true
      can_radial_attack = false
      enemy:radial_attack()
      if enemy:get_life() < FULL_HEALTH/2 then enemy:spoke_sparks() end
      sol.timer.start(map, 8000, function() can_radial_attack = true end)

    elseif can_skeleton_hands then
      attacking = true
      can_skeleton_hands = false
      enemy:skeleton_hands() enemy:pollute_blast()
      sol.timer.start(map, 9000, function() can_skeleton_hands = true end)

    elseif can_rune_barrage and enemy:get_life() < FULL_HEALTH*2/3 then
      attacking = true
      can_rune_barrage = false
      enemy:rune_barrage()
      sol.timer.start(map, 20000, function() can_rune_barrage = true end)

    elseif can_pollute_blast and enemy:get_life() > FULL_HEALTH*2/3 then
      attacking = true
      can_pollute_blast = false
      enemy:pollute_blast()
      sol.timer.start(map, 14000, function() can_pollute_blast = true end)

    elseif can_teleport_shot then
      attacking = true
      can_teleport_shot = false
      enemy.teleport_shotting = true
      if enemy:get_life() > FULL_HEALTH*2/3 then enemy:teleport_shot()
      else enemy:teleport_dash() end
      sol.timer.start(map, 9000, function() can_teleport_shot = true end)

    elseif can_gross_dash then
      attacking = true
      can_gross_dash = false
      enemy:gross_dash()
      sol.timer.start(map, 8000, function() can_gross_dash = true end)

    elseif can_summon_crystals then
      attacking = true
      can_summon_crystals = false
      enemy:summon_crystals()
      sol.timer.start(map, 10000, function() can_summon_crystals = true end)

    elseif can_pattern_attack and enemy:get_life() > game:get_value("sword_damage") then
      attacking = true
      can_pattern_attack = false
      enemy:pattern_attack()
      sol.timer.start(map, 21000, function() can_pattern_attack = true end)

    elseif can_tide_attack and enemy:get_life() > game:get_value("sword_damage") then
      attacking = true
      can_tide_attack = false
      enemy:tide_attack()
      sol.timer.start(map, 15000, function() can_tide_attack = true end)

    elseif can_surround_attack and enemy:get_distance(hero) < 300 then
      attacking = true
      can_surround_attack = false
      enemy:surround_attack()
      sol.timer.start(map, 18000, function() can_surround_attack = true end)

    elseif can_summon_helpers then
      attacking = true
      can_summon_helpers = false
      enemy:summon_helpers()
      sol.timer.start(map, 10000, function() can_summon_helpers = true end)



    end

  end  
end


--==================================================================================--
-----------------------------ATTACKS--------------------------------------------------
--==================================================================================--

--Throw Sword
function enemy:throw_sword()
  local SPEED = 200
  local DISTANCE = 180
  sprite:set_animation("wind_up_sword")
  local m = sol.movement.create("straight")
  m:set_angle(hero:get_angle(enemy))
  m:set_speed(150)
  m:set_max_distance(120)
  m:start(enemy)
  sol.timer.start(map, 800, function()
    sprite:set_animation("attack", function()
      sprite:set_animation("walking")
    end)
    local x, y, layer = enemy:get_position()
    local boomerang = enemy:create_enemy({
      name = "enemy_thrown_boomerang",
      x = 0, y = 0, layer = layer, direction = 0, breed = "misc/enemy_weapon"
    })
    boomerang:set_damage(enemy:get_damage())
    boomerang:set_obstacle_behavior("flying")
    local sprite = boomerang:create_sprite("enemies/misc/spirit_sword")

    --sound
    sol.timer.start(enemy, 160, function()
      if enemy:get_map():has_entities("enemy_thrown_boomerang") then
        sol.audio.play_sound("boomerang")
        return true
      end
    end)

    local m2 = sol.movement.create("straight")
    m2:set_angle(enemy:get_angle(hero))
    m2:set_max_distance(DISTANCE)
    m2:set_speed(SPEED)
    m2:set_ignore_obstacles(true)
    m2:start(boomerang, function()
      sol.timer.start(map, 200, function()
        local m3 = sol.movement.create("target")
        m3:set_target(enemy)
        m3:set_ignore_obstacles(true)
        m3:set_speed(SPEED)
        m3:start(boomerang, function()
          boomerang:remove()
        end)
      end)
    end)

    function m2:on_obstacle_reached()
      sol.audio.play_sound("thunk1")
      boomerang:remove()
    end

    sol.timer.start(map, 1000, function() enemy:finish_attacking() end)

  end)
end


--Surround the hero with projectiles
function enemy:surround_attack()
  local fires = {}
  local NUM_PROJECTILES = 10
  local RADIUS = 112
  local DELAY = 1500
  local ZOOM_SPEED = 120

  sprite:set_animation("wind_up")
  sol.timer.start(map, 1000, function()
    sol.timer.start(enemy, 1000, function() sprite:set_animation("walking") end)
    sol.audio.play_sound("fire_burst_1")
    for i=1, NUM_PROJECTILES do
      fires[i] = enemy:create_enemy{breed = "misc/curse_skull"}
      local m = sol.movement.create("circle")
      m:set_center(hero)
      m:set_radius(RADIUS)
      m:set_angle_from_center(math.pi * 2 / NUM_PROJECTILES * i)
      m:set_angular_speed(2)
      m:set_ignore_obstacles()
      m:start(fires[i])
    end

    sol.timer.start(map, DELAY, function()
      sol.audio.play_sound("shoot_magic_2")
      for i=1, NUM_PROJECTILES do
        if fires[i] then
          local m = sol.movement.create("straight")
          m:set_speed(ZOOM_SPEED)
          m:set_angle(fires[i]:get_angle(hero))
          m:set_max_distance(fires[i]:get_distance(hero))
          m:set_ignore_obstacles()
          m:start(fires[i])
          function m:on_finished()
            fires[i]:remove()
          end
        end
      end
    end)

    sol.timer.start(map, 2000, function() enemy:finish_attacking() end)

  end)
end


--Sweeping projectile attack
function enemy:tide_attack()
    sweeping = true
    sol.audio.play_sound("fire_burst_3")
    sprite:set_animation("invisible")
    smoke_sprite:set_animation("invisible")
    local x, y, l = enemy:get_position()
    local xref, yref = map:get_entity("boss_teleport_ref"):get_position()
    enemy:teleport_to(x, yref, l)
    local m = sol.movement.create("straight")
    local angle = math.random(1,2) * math.pi
    m:set_angle(angle)
    m:set_speed(250)
    m:start(enemy)
    function m:on_obstacle_reached()
      map:create_poof(enemy:get_position())
      sol.audio.play_sound("fire_burst_3")
      sprite:set_animation("wind_up")
      smoke_sprite:set_animation("walking")
      m:set_angle(angle + math.pi)
      m:start(enemy)
      local breathing_fire = true
      sol.timer.start(enemy, 150, function()
        local fire = enemy:create_enemy{breed="misc/curse_skull"}
        local mf = sol.movement.create("straight")
        mf:set_angle(3*math.pi/2)
        mf:set_speed(150)
        mf:set_max_distance(250)
        mf:set_ignore_obstacles()
        mf:start(fire)
        sol.audio.play_sound("shoot_magic")
        function mf:on_obstacle_reached() fire:remove() end
        function mf:on_finished() fire:remove() end
        sol.timer.start(map, 3000, function() fire:remove() end)
        if breathing_fire then return true end
      end)

      function m:on_obstacle_reached()
        enemy:set_default_attack_consequences()
        breathing_fire = false
        sweeping = false
        sol.timer.start(map, 30, function() enemy:finish_attacking() end)
      end
      function m:on_finished()
        enemy:set_default_attack_consequences()
        breathing_fire = false
        sweeping = false
        sol.timer.start(map, 30, function() enemy:finish_attacking() end)
      end

    end
end


--Summon additional enemies
function enemy:summon_helpers()

  enemy:finish_attacking()
end



--Summon blasts in a pattern on the floor
function enemy:pattern_attack()
  enemy:stop_movement()
  local xref, yref, lref = map:get_entity("boss_teleport_ref"):get_position()
  map:create_poof(enemy:get_position())
  map:create_poof(xref, yref, lref)
  sol.audio.play_sound("fire_burst_3")
  sprite:set_animation("invisible")
  enemy:set_position(xref, yref, lref)
  sprite:set_animation("wind_up")
  sol.audio.play_sound("charge_1")
  sol.timer.start(map, 1000, function()
    sol.timer.start(enemy, 1000, function()
      sprite:set_animation("walking")
      sol.audio.play_sound"charge_2_monster"
      smoke_sprite:set_animation("walking")
    end)

    local NUM_IN_ROW = 6
    local X_SPACING = 48
    local function create_row(y)
      for i=1, NUM_IN_ROW do
        enemy:create_enemy{
          x = -NUM_IN_ROW * X_SPACING + (i-1) * X_SPACING + (NUM_IN_ROW / 2 * X_SPACING + X_SPACING - 8),
          y = y, breed = "misc/curse_blast"
        }
      end
    end

    for i=1, 3 do
      create_row(i*64 - 56)
    end
    sol.audio.play_sound("fire_burst_1")
    sol.timer.start(map, 1500, function() enemy:finish_attacking() end)
  end)
end

--rune barrage, pollute blast, teleport shot, gross dash, and summon crystals
--These are from Blackbeard:

--Pollute Blast
function enemy:pollute_blast()
  enemy:stop_movement()
  sprite:set_animation("wind_up_rune")
  sol.audio.play_sound"charge_1"
  sol.timer.start(map, 900, function()
    sprite:set_animation("walking")
    local offset_x = {[0]=32,[1]=0,[2]=-32,[3]=0,[4]=0}
    local offset_y = {[0]=0,[1]=32,[2]=0,[3]=-32,[4]=0}
    for i=0,4 do
      enemy:create_enemy{breed="misc/black_blast",
      x=offset_x[i], y=offset_y[i]}
    end
    for i=0, 4 do
      sol.timer.start(map, math.random(200,800), function()
        local x=offset_x[i] + math.random(-16,16)
        local y=offset_y[i] + math.random(-16,16)
        if not enemy:test_obstacles(x,y) then
          sol.audio.play_sound"pollution_puddle"
          enemy:create_enemy{
            breed="misc/pollution_puddle",
            x=x,y=y
          }
        end
      end)
    end
    sol.timer.start(map, 900, function() enemy:finish_attacking() end)
  end)
end


--Rune Barrage
function enemy:rune_barrage()
  local MAX_RUNES = math.random(12,16)
  enemy:stop_movement()
  enemy:teleport_to(map:get_entity("boss_teleport_ref"):get_position())
  sol.audio.play_sound"charge_2"
  sprite:set_animation"wind_up_rune"
  sol.timer.start(map, 1000, function()
    local i = 1
    sol.timer.start(map, 250, function()
      local y = math.random(-80, 120)
      local x = math.random(-140, 140)
      if not enemy:test_obstacles(x,y) then
        sol.audio.play_sound("fire_burst_1")
        local e = enemy:create_enemy{breed="misc/curse_blast",x=x,y=y}
      end
      i = i + 1
      if i <= MAX_RUNES then
        return true
      else
        enemy:finish_attacking()
      end
    end)
  end) --end of 1k timer after teleporting
end

--Gross Dash
function enemy:gross_dash()
  enemy:stop_movement()
  sprite:set_animation"wind_up"
  sol.timer.start(map, 400, function()
    local m = sol.movement.create("straight")
    m:set_speed(180)
    m:set_max_distance(500)
    m:set_angle(enemy:get_angle(hero))
    sprite:set_animation"walking"
    sol.audio.play_sound"dash_big"
    puddling = true
    m:start(enemy, function() enemy:finish_attacking() end)
    function m:on_obstacle_reached()
      enemy:finish_attacking()
    end
    sol.timer.start(map, 200, function()
      if puddling then
        sol.audio.play_sound"pollution_puddle"
        enemy:create_enemy{breed="misc/pollution_puddle"}
        return true
      end
    end)
  end)
end


--Teleport Shot
local teleport_shot_counter = 0
local previous_teleport_spot = 5
function enemy:teleport_shot()
  enemy:stop_movement()
  local NUM_SHOTS = 3
  teleport_shot_counter = teleport_shot_counter + 1
  if teleport_shot_counter <= NUM_SHOTS then
    local new_teleport_spot = math.random(2,5)
    while previous_teleport_spot == new_teleport_spot do
      new_teleport_spot = math.random(2,5)
    end
    previous_teleport_spot = new_teleport_spot
    enemy:teleport_to(map:get_entity("boss_teleport_ref_" .. new_teleport_spot):get_position())
    sprite:set_animation("wind_up_rune", "walking")
    sprite:set_direction(enemy:get_direction4_to(hero))
    sol.timer.start(map, 600, function()
      enemy:make_bomb_go()
      enemy:teleport_shot()
    end)
  else
    teleport_shot_counter = 0
    enemy:finish_attacking()
  end  
end

function enemy:make_bomb_go(type)
  local breed = type or "misc/energy_ball_black"
  local bomb = enemy:create_enemy{breed=breed}
  sol.audio.play_sound"hand_cannon"
  bomb:go(enemy:get_angle(hero))
end

--Teleport Dash
local teleport_dash_counter = 0
function enemy:teleport_dash()
  enemy:stop_movement()
  local NUM_SHOTS = 3
  teleport_dash_counter = teleport_dash_counter + 1
  if teleport_dash_counter <= NUM_SHOTS then
    local new_teleport_spot = math.random(2,5)
    while previous_teleport_spot == new_teleport_spot do
      new_teleport_spot = math.random(2,5)
    end
    previous_teleport_spot = new_teleport_spot
    enemy:teleport_to(map:get_entity("boss_teleport_ref_" .. new_teleport_spot):get_position())
    sprite:set_animation("invisible")
    sprite:set_direction(enemy:get_direction4_to(hero))
    sol.timer.start(map, 400, function()
      local m = sol.movement.create("straight")
      m:set_angle(enemy:get_angle(hero))
      m:set_speed(250)
      m:set_max_distance(300)
      sprite:set_animation"invisible"
      --create ghosts
      local how_many_ghosts = 1
      sol.timer.start(map, 50, function()
        local e = enemy:create_enemy{breed="misc/enemy_weapon"}
        e:set_damage(20)
        e:set_sprite("enemies/bosses/abyss_beast_ghost")
        e:get_sprite():set_animation("evaporating", function() e:remove() end)
        how_many_ghosts = how_many_ghosts + 1
        if how_many_ghosts <= 20 then return true end
      end)
      --actually start dash
      sol.audio.play_sound"delay_charge"
      m:start(enemy, function()
        sprite:set_animation"walking"
        enemy:teleport_dash()
      end)
      function m:on_obstacle_reached()
        sprite:set_animation"walking"
        enemy:teleport_dash()
      end
    end)
  else
    teleport_dash_counter = 0
    sprite:set_animation"walking"
    enemy:finish_attacking()
  end  
end


--Radial Attack
function enemy:radial_attack()
  enemy:stop_movement()
  enemy:teleport_to(map:get_entity("boss_teleport_ref"):get_position())
  sprite:set_animation("wind_up")
  sol.audio.play_sound"charge_3"
  sol.timer.start(map, 1000, function()
    local NUM_PROJECTILES = 8
    for i=1, NUM_PROJECTILES do
      local projectile = enemy:create_enemy{breed="misc/energy_ball_black_2"}
      projectile:go(math.pi*2/NUM_PROJECTILES*i + math.pi*2/(NUM_PROJECTILES*2))
    end
    sol.audio.play_sound("shoot_magic_2")
    sprite:set_animation"walking"
    sol.timer.start(map, 1000, function() enemy:finish_attacking() end)
  end)
end


--Summon obstacles
function enemy:summon_crystals()
  enemy:stop_movement()
  sprite:set_animation("wind_up_rune")
  sol.audio.play_sound"charge_2_monster"
  sol.timer.start(map, 1500, function()
    local offset_x = {[0]=32,[1]=0,[2]=-32,[3]=0,[4]=0}
    local offset_y = {[0]=0,[1]=32,[2]=0,[3]=-32,[4]=0}
    for i=0,4 do
      local x=offset_x[i] + math.random(-16,16)
      local y=offset_y[i] + math.random(-16,16)
      if not enemy:test_obstacles(x,y) then
        sol.timer.start(map, math.random(1000), function()
          local obstacle = enemy:create_enemy{breed="misc/pollutant_blocker",x=x,y=y}
          sol.timer.start(map, 6000, function() obstacle:hurt(100) end)
        end)
      end
    end
    sprite:set_animation"walking"
    enemy:finish_attacking()
  end)
end


--Skeleton Hands
function enemy:skeleton_hands()
  local NUM_HANDS = 7
  local i = 1
  sol.timer.start(map, 250, function()
    if i <= NUM_HANDS and enemy:get_life() > 0 then
      local x,y,l = hero:get_position()
      map:create_enemy{breed="misc/skeleton_hand",x=x,y=y,layer=l,direction=0}
      i = i + 1
      return true
    end
  end)
end

--Line of Blasts
function enemy:line_of_blasts(sx,sy,sl,angle,dist)
  local leader = map:create_custom_entity{x=sx,y=sy,layer=sl,direction=0,width=16,height=16}
  local m = sol.movement.create("straight")
  m:set_max_distance(dist)
  m:set_angle(angle)
  m:set_speed(200)
  m:start(leader, function() leader:remove() end)
  function m:on_obstacle_reached() leader:remove() end
  local NUM_BLASTS = 8
  local i = 0
  sol.timer.start(map, 150, function()
    local x,y,l = leader:get_position()
    map:create_enemy{breed="misc/curse_blast",x=x,y=y,layer=l,direction=0}
    i = i + 1
    if i <= NUM_BLASTS then return true end
  end)
end


--Spoke Sparks
function enemy:spoke_sparks()
  sol.audio.play_sound"charge_2_monster"
  local NUM_SPOKES = 8
  local sx,sy,sl = enemy:get_position()
  for i=1,NUM_SPOKES do
    local dist = 150
    local angle = math.pi * 2 / NUM_SPOKES * i
    enemy:line_of_blasts(sx,sy,sl,angle,dist)
  end
end

--remove this one later:
function enemy:unlock_pattern_attack()
end

