local enemy = ...
local map = enemy:get_map()
local particles = {}
local MAX_PARTICLES = 3
local PARTICLE_SPEED = 11
enemy.immobilize_immunity = true
enemy.lighting_effect = 1

function enemy:on_created()
  local map = enemy:get_map()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(16)
  enemy:set_obstacle_behavior("flying")
  enemy:set_can_hurt_hero_running(true)
  enemy:set_invincible()
  enemy:set_dying_sprite_id("enemies/enemy_killed_projectile")
  enemy:set_attack_consequence("sword", "custom")
  enemy:set_attack_consequence("arrow", "ignored")

  --particle effect
  local i = 1
  sol.timer.start(map, math.random(100,250), function()
    particles[i] = sol.sprite.create("entities/pollution_ash")
    particles[i]:set_xy(math.random(-20, 20), math.random(-24, 0))
    local m = sol.movement.create("random")
    m:set_speed(PARTICLE_SPEED)
--    m:set_ignore_suspend(false)
    m:start(particles[i])
    i = i + 1
    if i > MAX_PARTICLES then i = 0 end
    if enemy:exists() and enemy:is_enabled() then return true end
  end)

end

--particle effect draw
function enemy:on_post_draw()
    local x, y, layer = enemy:get_position()
    for i=1, #particles do
      map:draw_visual(particles[i], x, y)
    end
end


function enemy:go(direction)
  local movement = sol.movement.create("straight")
  movement:set_speed(100)
  movement:set_angle(direction)
  movement:set_smooth(false)
  movement:start(enemy)

  function movement:on_obstacle_reached()
    enemy:remove()
  end
end


-- Change the direction of the movement when hit with the sword.
function enemy:on_custom_attack_received(attack, sprite)
  if attack == "sword" and enemy:get_movement() then
    enemy:go(enemy:get_map():get_hero():get_angle(enemy))
    sol.audio.play_sound("enemy_hurt")
  end
end