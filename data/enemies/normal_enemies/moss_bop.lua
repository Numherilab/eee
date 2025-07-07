local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement
local above_ground

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(2)
  enemy:set_damage(1)
  above_ground = true
end

local function close_to_hero()
  if enemy:get_distance(hero) <= 200 and
  enemy:is_in_same_region(hero) then
    return true
  end
end

function enemy:on_restarted()
  enemy:burrow()
end

function enemy:move()
  movement = sol.movement.create"random_path"
  movement:start(enemy)
end

function enemy:burrow()
  sprite:set_animation"invisible"
  local x,y,z = enemy:get_position()
  local effect = map:create_custom_entity{
    direction = 0, x=x, y=y+2, layer = z, width = 16, height = 16, sprite = "enemies/misc/moss_bop_grass"
  }
  effect:get_sprite():set_animation("burst", function() effect:remove() end)
  if close_to_hero() then sol.audio.play_sound"bush" end
  sol.timer.start(enemy, math.random(2500, 5500), function()
      enemy:arise()
  end)
end

function enemy:arise()
  enemy:stop_movement()
  local x,y,z = enemy:get_position()
  local effect = map:create_custom_entity{
    direction = 0, x=x, y=y+2, layer = z, width = 16, height = 16, sprite = "enemies/misc/moss_bop_grass"
  }
  effect:get_sprite():set_animation("walking")
  sol.timer.start(map, 1000, function()
    effect:get_sprite():set_animation("burst", function() effect:remove() end)
    if close_to_hero() then sol.audio.play_sound"bush" end
    sprite:set_animation"walking"
    sol.timer.start(enemy, 200, function() enemy:shoot() end)
    enemy:move()
    sol.timer.start(enemy, 2200, function()
      enemy:burrow()
    end)
  end)
end

function enemy:shoot()
  local projectile = enemy:create_enemy{
    breed = "misc/energy_ball_small"
  }
  projectile:set_damage(1)
  projectile:go(enemy:get_angle(hero))
end

enemy.weak_to_fire = true
function enemy:react_to_fire()
  enemy:propagate_fire()
end

