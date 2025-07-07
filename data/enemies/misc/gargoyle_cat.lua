local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement
local can_shoot
enemy.immobilize_immunity = true

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
--  enemy:set_traversable(false) --can't shoot projectiles if that's true
  enemy:set_damage(1)
  enemy:set_invincible()
  enemy:set_size(32, 24)
  enemy:set_attacking_collision_mode("overlapping")
  enemy:set_size(32,16)
end

function enemy:on_restarted()
 enemy:check_hero()
  can_shoot = true
end

function enemy:check_hero()
--print("check hero")
  if enemy:get_distance(hero) < 150 and enemy:is_in_same_region(hero) and can_shoot then
    can_shoot = false
    enemy:shoot()
  end
  sol.timer.start(enemy, 100, function() enemy:check_hero() end)
end


function enemy:shoot()
  sprite:set_animation"charging"
  sol.timer.start(enemy, 1000, function()
    sprite:set_animation"stopped"
    local projectile = enemy:create_enemy{
      breed="misc/energy_ball_bounce"
    }
    projectile:set_max_bounces(1)
    projectile:set_damage(1)
    projectile:go(enemy:get_angle(hero))
  end)
  sol.timer.start(enemy, 3500, function()
    can_shoot = true
  end)
end

function enemy:get_hurt_by_reflected_attack()
  enemy:hurt(1)
end