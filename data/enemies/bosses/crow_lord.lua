local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local angle = 0
local FULL_HEALTH = 400
local attacking = false
enemy.immobilize_immunity = true
enemy.height = 24

-- Event called when the enemy is initialized.
function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
--  smoke_sprite = enemy:create_sprite("enemies/ghost_smoke_large")
--  smoke_sprite:set_blend_mode("blend")
--  enemy:bring_sprite_to_back(smoke_sprite)
--  enemy:set_invincible_sprite(smoke_sprite)

  enemy:set_life(300)
  enemy:set_damage(23)
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_hurt_style("boss")
end



function enemy:go_hero()
  local m = sol.movement.create("target")
  m:set_speed(50)
--  m:start(enemy)
end


function enemy:on_restarted()
  enemy:go_hero()
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
  enemy:create_feathers(a,b+5,c)
  enemy:set_position(x,y,l)
  a,b,c = enemy:get_position()
  enemy:create_feathers(a,b+5,c)
end

function enemy:create_feathers(x,y,l)
  for i=1, 10 do
    local feather = map:create_custom_entity{
      direction=math.random(0,3), width=16, height=16, layer = l,
      x = x+math.random(-24,24), y=y+math.random(-40,16),
      sprite = "enemies/crow_feather", model = "ephemeral_effect"
    }
    local m = sol.movement.create("straight")
    m:set_angle(math.random(3*math.pi/2-.5,3*math.pi/2+.5))
    m:start(feather)
    sol.timer.start(map, 2000, function() feather:remove() end)
  end
end

local can_summon_crows = true
local can_teleport = true
local can_pollute_blast = true
local can_teleport_shot = true
--local can_radial_attack = true

--Select an Attack:
function enemy:check_to_attack()
  if not attacking then

    if can_summon_crows then
      attacking = true
      can_summon_crows = false
      enemy:summon_crows()
      if enemy:get_life() < FULL_HEALTH/2 then enemy:spoke_sparks() end
      sol.timer.start(map, 5000, function() can_summon_crows = true end)

    elseif can_teleport then
      attacking = false
      can_teleport = false
      enemy:teleport_attack()
      sol.timer.start(map, 5000, function() can_teleport = true end)

    elseif can_radial_attack then
      attacking = true
      can_radial_attack = false
      enemy:radial_attack()
      if enemy:get_life() < FULL_HEALTH/2 then enemy:spoke_sparks() end
      sol.timer.start(map, 11000, function() can_radial_attack = true end)

    elseif can_pollute_blast and enemy:get_life() > FULL_HEALTH*2/3 then
      attacking = true
      can_pollute_blast = false
      enemy:pollute_blast()
      sol.timer.start(map, 10000, function() can_pollute_blast = true end)

    elseif can_teleport_shot then
      attacking = true
      can_teleport_shot = false
      enemy:teleport_shot()
      sol.timer.start(map, 9000, function() can_teleport_shot = true end)

    end

  end  
end





-----------------------------------Attacks---------------------------------------------

function enemy:summon_crows()
  enemy:stop_movement() --don't move while summoning the orbiting projectiles
  local sprite = enemy:get_sprite()
  local x, y, layer = enemy:get_position()
  local direction = sprite:get_direction()
  local projectiles = {}
  local NUM_PROJECTILES = 4
  local CHARGE_TIME = 800
  local SHOOT_DELAY = 1000
  sprite:set_animation("raise_wings", "wings_up")
  for i=1, NUM_PROJECTILES do
    sol.timer.start(map, CHARGE_TIME/NUM_PROJECTILES * i, function()
      if enemy:get_life() >= 1 then
        sol.audio.play_sound("summon_in")
        projectiles[i] = map:create_enemy({
          x = x, y = y, layer = layer, direction = direction,
          breed = "normal_enemies/crow"
        })
        projectiles[i]:set_damage(10)
        local m = sol.movement.create("circle")
        m:set_center(enemy)
        m:set_radius(48)
        m:set_angular_speed(8)
        m:set_ignore_obstacles(true)
        m:start(projectiles[i])
      end
      if i == NUM_PROJECTILES then sprite:set_animation("walking") end
    end)
  end
  sol.timer.start(map, CHARGE_TIME, function() enemy:finish_attacking() end)
end


--Teleport Attack
function enemy:teleport_attack()
  local NUM_TELEPORT_SPOTS = 5
  local destination = "boss_teleport_ref_" .. math.random(1,NUM_TELEPORT_SPOTS)
  if map:get_entity(destination):get_distance(enemy) < 24 then
    enemy:teleport_attack()
  else
    enemy:teleport_to(map:get_entity(destination):get_position())
  end
end


--Pollute Blast
function enemy:pollute_blast()
  enemy:stop_movement()
  sprite:set_animation("raise_wings", "wings_up")
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
      new_teleport_spot = math.random(1,5)
    end
    previous_teleport_spot = new_teleport_spot
    enemy:teleport_to(map:get_entity("boss_teleport_ref_" .. new_teleport_spot):get_position())
    sprite:set_animation("raise_wings", "walking")
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
  local breed = type or "misc/energy_ball_black_2"
  local bomb = enemy:create_enemy{breed=breed}
  bomb:set_damage(13)
  sol.audio.play_sound"shoot_magic_2"
  bomb:go(enemy:get_angle(hero))
end


--Line of Blasts
function enemy:line_of_blasts(sx,sy,sl,angle,dist)
  local leader = map:create_custom_entity{x=sx,y=sy,layer=sl,direction=0,width=16,height=16}
  local m = sol.movement.create("straight")
  m:set_max_distance(dist)
  m:set_angle(angle)
  m:set_speed(200)
  m:set_smooth(false)
  m:start(leader, function() leader:remove() end)
  function m:on_obstacle_reached() leader:remove() end
  local NUM_BLASTS = 8
  local i = 0
  sol.timer.start(map, 150, function()
    local x,y,l = leader:get_position()
    map:create_enemy{breed="misc/skeleton_hand",x=x,y=y,layer=l,direction=0}
    i = i + 1
    if i <= NUM_BLASTS then return true end
  end)
end


--Spoke Sparks
function enemy:spoke_sparks()
  sol.audio.play_sound"charge_2_monster"
  local NUM_SPOKES = 6
  local sx,sy,sl = enemy:get_position()
  for i=1,NUM_SPOKES do
    local dist = 150
    local angle = math.pi * 2 / NUM_SPOKES * i
    enemy:line_of_blasts(sx,sy,sl,angle,dist)
  end
end
