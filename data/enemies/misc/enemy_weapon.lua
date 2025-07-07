local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement
enemy.immobilize_immunity = true

-- Event called when the enemy is initialized.
function enemy:on_created()
  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:set_invincible()
  enemy:set_attack_consequence("sword", "protected")
  enemy:set_obstacle_behavior("flying")
  enemy:set_push_hero_on_sword(true)
end

function enemy:on_restarted()

end

function enemy:set_sprite(sprite_path)
  enemy:create_sprite(sprite_path)
end