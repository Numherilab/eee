-- Bomb thrown by arborgeist bombers.

local enemy = ...
local map = enemy:get_map()
enemy.immobilize_immunity = true

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_size(8, 8)
  enemy:set_origin(4, 4)
  enemy:set_invincible()
  enemy:set_dying_sprite_id("enemies/enemy_killed_small")
  enemy:set_obstacle_behavior("flying")
end

function enemy:on_obstacle_reached()
  local bombx, bomby, bomblayer = enemy:get_position()
  sol.audio.play_sound("explosion")
  map:create_explosion({
    layer = bomblayer,
    x = bombx,
    y = bomby,
  })
  enemy:remove()
end

function enemy:go(direction4)

  local angle = direction4 * math.pi / 2
  local movement = sol.movement.create("straight")
  movement:set_speed(150)
  movement:set_angle(angle)
  movement:set_smooth(false)
  movement:start(enemy)

  enemy:get_sprite():set_direction(direction4)
end


function enemy:on_hurt()
  sol.audio.play_sound("explosion")
  local bombx, bomby, bomblayer = enemy:get_position()
  map:create_explosion({
    layer = bomblayer,
    x = bombx,
    y = bomby,
  })
  enemy:remove()
end