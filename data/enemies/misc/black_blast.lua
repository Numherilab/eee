local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement
enemy.immobilize_immunity = true
enemy.lighting_effect = 1
enemy.height = 16

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(100)
  enemy:set_damage(2)
  enemy:set_invincible(true)
end

function enemy:on_restarted()
  sprite:set_animation("stopped", function()
    enemy:remove()
  end)
end
