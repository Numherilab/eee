-- Lua script of enemy misc/stone_dragon_turret.
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
enemy.immobilize_immunity = true

local DETECTION_DISTANCE = 180
local SHOOT_FREQUENCY = 3000
local PROJECTILE_BREED = "misc/energy_ball_small"
local can_shoot

-- Event called when the enemy is initialized.
function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:set_invincible(true)

  can_shoot = true
end


local function hero_nearby()
  if hero:get_layer() == enemy:get_layer() and enemy:get_distance(hero) <= DETECTION_DISTANCE and enemy:is_in_same_region(hero) then
    return true
  end
end

function enemy:on_restarted()
  sol.timer.start(enemy, math.random(SHOOT_FREQUENCY - 500, SHOOT_FREQUENCY + 500), function()
    if hero_nearby() then
      enemy:shoot()
    end
    return math.random(SHOOT_FREQUENCY - 500, SHOOT_FREQUENCY + 500)
  end)
end


function enemy:shoot()
  sol.audio.play_sound("shoot_magic")
  local projectile = enemy:create_enemy({ breed = PROJECTILE_BREED,y=-5})
  projectile:go(enemy:get_angle(hero))
end
