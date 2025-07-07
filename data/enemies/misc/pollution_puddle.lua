local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement
enemy.immobilize_immunity = true

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(100)
  enemy:set_damage(2)
  enemy:set_invincible(true)
  enemy:set_drawn_in_y_order(false)
end

function enemy:on_restarted()
  sprite:set_direction(math.random(1,2))
  sprite:set_animation("stopped", function()
    enemy:remove()
  end)
end
