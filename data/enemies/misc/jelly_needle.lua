local enemy = ...
local sprite
local bounces = 0
local MAX_BOUNCES = 2
local FUSE_LENGTH = 3000
enemy.immobilize_immunity = true

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(8)
  enemy:set_origin(4, 4)
  enemy:set_obstacle_behavior("flying")
  enemy:set_layer_independent_collisions(true)
  enemy:set_can_hurt_hero_running(true)
  enemy:set_dying_sprite_id("enemies/enemy_killed_projectile")
  enemy:set_attack_consequence("arrow", "ignored")
  bounces = 0
end

function enemy:on_movement_changed(m)
  sprite:set_direction(m:get_direction4())
end

function enemy:set_max_bounces(amount)
  MAX_BOUNCES = amount
end

function enemy:go(direction)
  local movement = sol.movement.create("straight")
  movement:set_speed(100)
  movement:set_angle(direction)
  movement:set_smooth(false)
  movement:set_ignore_obstacles(true)
  movement:start(enemy)
-- print(movement:get_ignore_obstacles())



  sol.timer.start(enemy, FUSE_LENGTH, function() enemy:remove() end)
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