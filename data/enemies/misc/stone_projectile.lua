local enemy = ...
enemy.immobilize_immunity = true

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(4)
--  enemy:set_origin(4, 4)
  enemy:set_obstacle_behavior("flying")
  enemy:set_can_hurt_hero_running(true)
  enemy:set_dying_sprite_id("enemies/enemy_killed_small")
end


function enemy:go(direction)
  local movement = sol.movement.create("straight")
  movement:set_speed(100)
  movement:set_angle(direction)
  movement:set_smooth(false)
  movement:start(enemy)

  function movement:on_obstacle_reached()
    enemy:stop_movement()
    enemy:remove_life(2)
  end
end

function enemy:on_hurt()
  enemy:stop_movement()
end

enemy:register_event("on_attacking_hero", function(enemy, hero, enemy_sprite)
  hero:start_hurt(enemy, enemy:get_damage())
  enemy:stop_movement()
  enemy:remove_life(200)
end)