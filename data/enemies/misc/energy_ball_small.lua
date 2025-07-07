local enemy = ...
local bounces = 0
local MAX_BOUNCES = 1
local FUSE_LENGTH = 2000
enemy.immobilize_immunity = true
enemy.lighting_effect = 1

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/misc/energy_ball_small")
  enemy:set_life(1)
  enemy:set_damage(3)
  enemy:set_size(8,8)
  enemy:set_origin(4, 4)
  enemy:set_obstacle_behavior("flying")
  enemy:set_can_hurt_hero_running(true)
  enemy:set_invincible()
  enemy:set_dying_sprite_id("enemies/enemy_killed_projectile")
  enemy:set_attack_consequence("sword", "custom")
  enemy:set_attack_consequence("arrow", "ignored")
  bounces = 0
end

function enemy:set_max_bounces(amount)
  MAX_BOUNCES = amount
end

function enemy:go(direction)
  local movement = sol.movement.create("straight")
  movement:set_speed(100)
  movement:set_angle(direction)
  movement:set_smooth(false)
  movement:start(enemy)

  function movement:on_obstacle_reached()
    if bounces < MAX_BOUNCES then
      bounces = bounces + 1
      enemy:go(enemy:get_new_direction())
    else
      enemy:remove()
    end
  end

  sol.timer.start(enemy, FUSE_LENGTH, function() enemy:remove() end)
end


-- Destroy the fireball when the hero is touched.
enemy:register_event("on_attacking_hero", function(enemy, hero, enemy_sprite)
  hero:start_hurt(enemy, enemy_sprite, enemy:get_damage())
  enemy:remove()
end)

-- Change the direction of the movement when hit with the sword.
function enemy:on_custom_attack_received(attack, sprite)
  if attack == "sword" then
    sol.audio.play_sound("enemy_hurt")
    enemy:go(enemy:get_angle(enemy:get_map():get_hero()) + math.pi)
  end
end



--Calculate New Direction
function enemy:get_new_direction()
  local wall_orientation = enemy:get_collision_wall_orientation()
  local current_angle = enemy:get_movement():get_angle()
  local new_angle
  if wall_orientation == "vertical" then
    new_angle = math.pi - current_angle
  else
    new_angle = 2*math.pi - current_angle
  end  
  return new_angle
end

--Get Wall Horiz or Vert
function enemy:get_collision_wall_orientation()
  if enemy:test_obstacles(8, 0) or enemy:test_obstacles(-8, 0) then return "vertical" end
  if enemy:test_obstacles(0, 8) or enemy:test_obstacles(0, -8) then return "hoirzontal" end
end