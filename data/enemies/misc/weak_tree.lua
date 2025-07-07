-- Lua script of enemy misc/explosive_barrel.
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
local barrel_x
local barrel_y
local barrel_layer
enemy.immobilize_immunity = true

-- Event called when the enemy is initialized.
function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(999)
  enemy:set_damage(0)
  enemy:set_hurt_style("monster")
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_traversable(false)
  enemy:set_attack_consequence("explosion", 1)
  enemy:set_attack_consequence("fire", 1)
  enemy:set_attack_consequence("sword", "protected")
  enemy:set_attack_consequence("arrow", "protected")
  enemy:set_dying_sprite_id("enemies/enemy_killed_small")
end

--make it so nothing happens when hero collides with tree
enemy:register_event("on_attacking_hero", function(enemy, hero, enemy_sprite)

end)


function enemy:on_hurt(sword)
    sol.audio.play_sound("arrow_hit")
end


function enemy:on_hurt(fire)
  sol.timer.start(300, function()
    sprite:set_animation("falling")
        sol.timer.start(200, function()
          enemy:set_enabled(false)
        end)
  end)
  sprite:set_animation("falling")
    sol.timer.start(200, function()
      enemy:set_enabled(false)
    end)

end

function enemy:on_hurt(explosion)
  sprite:set_animation("falling")
  enemy:set_enabled(false)

end
