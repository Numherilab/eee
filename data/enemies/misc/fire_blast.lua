-- Lua script of enemy misc/fire_blast.
-- This script is executed every time an enemy with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement
enemy.immobilize_immunity = true
enemy.lighting_effect = 2

-- Event called when the enemy is initialized.
function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:set_can_attack(false)
  enemy:set_invincible(true)
  enemy:set_attacking_collision_mode("overlapping")
  enemy:set_size(16,12)
end

function enemy:on_restarted()
  if enemy:is_on_screen() and not map.is_playing_fireburst_sound then
    sol.audio.play_sound("fire_burst_2")
    map.is_playing_fireburst_sound = true
    sol.timer.start(map, 100, function() map.is_playing_fireburst_sound = false end)
  end
  sprite:set_animation("charging", function()
    enemy:set_can_attack(true)
    sprite:set_animation("burning", function()
      enemy:remove()
    end)
  end)
  --in case enemy somehow wasn't removed properly
  sol.timer.start(enemy, 4000, function()
    enemy:remove()
  end)
end

