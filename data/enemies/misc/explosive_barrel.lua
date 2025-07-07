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

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(999)
  enemy:set_damage(0)
  enemy:set_can_attack(false)
  enemy:set_hurt_style("monster")
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_traversable(false)
  enemy:set_attack_consequence("explosion", 1)
  enemy:set_attack_consequence("fire", 1)
  enemy:set_attack_consequence("sword", "1")
  enemy:set_attack_consequence("arrow", "protected")
  
end

-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.

--make it so nothing happens when hero collides with barrel
enemy:register_event("on_attacking_hero", function(enemy, hero, enemy_sprite)

end)

--
function enemy:on_hurt(sword)
  local barrel_x, barrel_y, barrel_layer = enemy:get_position()
  enemy:set_enabled(false)
  map:create_explosion({
    x = barrel_x,
    y = barrel_y,
    layer = barrel_layer, })
    sol.audio.play_sound("explosion")
end
--]]

function enemy:on_hurt(fire)
  local barrel_x, barrel_y, barrel_layer = enemy:get_position()
  enemy:set_enabled(false)
  map:create_explosion({
    x = barrel_x,
    y = barrel_y,
    layer = barrel_layer, })
    sol.audio.play_sound("explosion")
end

function enemy:on_hurt(explosion)
  local barrel_x, barrel_y, barrel_layer = enemy:get_position()
  enemy:set_enabled(false)
  map:create_explosion({
    x = barrel_x,
    y = barrel_y,
    layer = barrel_layer, })
    sol.audio.play_sound("explosion")
end
--]]