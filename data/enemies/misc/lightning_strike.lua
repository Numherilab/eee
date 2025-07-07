local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

enemy.lighting_effect = 2

function enemy:on_created()

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:set_invincible(true)
  enemy:set_can_attack(false)
  enemy:set_attacking_collision_mode("overlapping")
  enemy:set_size(16,16)
end

function enemy:on_restarted()
  sol.audio.play_sound"crackle1"
  sprite:set_animation("sparking", function()
    enemy:set_can_attack(true)
    sol.audio.play_sound"thunder4_short"
    sprite:set_animation("striking", function() enemy:remove() end)
  end)
end
