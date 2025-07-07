local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement
enemy.immobilize_immunity = true
enemy.lighting_effect = 2

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(12)
  enemy:set_can_attack(false)
  enemy:set_invincible(true)
  enemy:set_attacking_collision_mode("overlapping")
  enemy:set_size(16,16)
end

function enemy:on_restarted()
--  if enemy:get_distance(hero) < 400 and enemy:is_in_same_region(hero) then sol.audio.play_sound("fire_burst_2") end
  sprite:set_animation("charging", function()
    enemy:set_can_attack(true)
    sprite:set_animation("burning", function()
      enemy:remove()
    end)
  end)
end
