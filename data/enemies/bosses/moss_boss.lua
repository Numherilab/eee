local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local attacking
local ATTACK_RANGE = 150
enemy.height = 20

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(14)
  enemy:set_damage(1)
  enemy:set_attack_consequence("sword", "protected")
  attacking = false
end

function enemy:get_hurt_by_reflected_attack()
  enemy:hurt(1)
end

function enemy:on_restarted()
  sol.timer.start(enemy, 80, function()
    enemy:check_hero()
    return true 
  end)
end

function enemy:check_hero()
  if enemy:is_in_same_region(hero) and enemy:get_distance(hero) <= ATTACK_RANGE then
    enemy:go_hero()
    if not attacking then enemy:choose_attack() end
  end
  if enemy:is_in_same_region(hero) and enemy:get_distance(hero) > ATTACK_RANGE then
    enemy:go_random()
  end
end

function enemy:go_hero()
  local movement = sol.movement.create("target")
  movement:set_target(hero)
  movement:set_speed(35)
  movement:start(enemy)
end

function enemy:go_random()
  local m = sol.movement.create"random_path"
  m:start(enemy)
end

function enemy:finish_attacking()
  attacking = false
  enemy:check_hero()
end

local can_throw = true
local can_surround = true
function enemy:choose_attack()
  if can_throw then
    attacking = true
    can_throw = false
    enemy:throw()
    sol.timer.start(map, 2000, function() can_throw = true end)

  elseif can_surround then
    attacking = true
    can_surround = false
    enemy:surround()
    sol.timer.start(map, 6000, function() can_surround = true end)
  end
end

--Throw a reflectable ball
function enemy:throw()
  enemy:stop_movement()
  sprite:set_animation"charging"
  sol.timer.start(map, 300, function()
    if not enemy:exists() then return end
    sprite:set_animation"walking"
    local ball = enemy:create_enemy{breed="misc/energy_ball_bounce", name="boss_ball"}
    ball:set_damage(1)
    ball:set_max_bounces(0)
    ball:go(enemy:get_angle(hero))
    sol.audio.play_sound("shoot_magic_2")
    enemy:finish_attacking()
  end)
end

--Surround the hero with projectiles
function enemy:surround()
  local fires = {}
  local NUM_PROJECTILES = 5
  local RADIUS = 112
  local DELAY = 1500
  local ZOOM_SPEED = 120
  enemy:stop_movement()
  sprite:set_animation("charging")
  sol.timer.start(map, 1000, function()
    sol.timer.start(enemy, 1000, function() sprite:set_animation("walking") end)
    if not enemy:exists() then return end
    sol.audio.play_sound("fire_burst_1")
    for i=1, NUM_PROJECTILES do
      fires[i] = enemy:create_enemy{breed = "misc/energy_ball_bounce", name="boss_ball"}
      fires[i]:set_damage(1)
      fires[i]:set_max_bounces(0)
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
    sol.timer.start(map, 3000, function() enemy:finish_attacking() end)
  end)
end