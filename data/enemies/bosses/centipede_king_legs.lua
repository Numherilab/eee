local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(16)
  enemy:set_damage(1)
end

function enemy:on_movement_changed()
  local direction = enemy:get_movement():get_direction4()
  enemy:get_sprite():set_direction(direction)
end

function enemy:on_restarted()

end
