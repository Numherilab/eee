local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement
local count
local amp
local speed
enemy.immobilize_immunity = true

-- Event called when the enemy is initialized.
function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:set_can_attack(false)
  count, amp, speed = 2, 4, 80
end

-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.
function enemy:on_restarted()
  enemy:set_invincible()
  enemy:set_layer(map:get_max_layer())
  sol.audio.play_sound"falling"
  sprite:set_animation("falling", function()
    sol.timer.start(enemy, 1, function()
      local x, y, z = enemy:get_position()
      if map:get_ground(x,y,z) == "empty" and enemy:get_layer() > map:get_min_layer() then
        enemy:set_layer(enemy:get_layer() - 1)
        return true
      end
    end)
    enemy:set_can_attack(true)
    sol.audio.play_sound"thunk1"
    map:get_camera():shake({count = count, amplitude = amp, speed = speed})
    sprite:set_animation("breaking", function()
      enemy:remove()
    end)
  end)
end


function enemy:set_shake_props(c,a,s)
  count, amp, speed = c,a,s
end
