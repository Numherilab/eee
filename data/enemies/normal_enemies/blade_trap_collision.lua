local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local sprite
enemy.immobilize_immunity = true

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_obstacle_behavior("flying")
  enemy:set_damage(2)
  enemy:set_size(24, 24)
  if enemy:get_property("damage") then enemy:set_damage(enemy:get_property("damage")) end
  enemy:set_invincible(true)
end


function enemy:on_restarted()
  local direction = (sprite:get_direction() * math.pi / 2)
  enemy:go(direction)
end

function enemy:go(direction)
  local direction_change = math.pi/2
  if enemy:get_property("clockwise") then
    direction_change = direction_change * -1
  end
  local m = sol.movement.create("straight")
  m:set_speed(enemy:get_property("speed") or 110)
  m:set_smooth(false)
  m:set_angle(direction)
  m:start(enemy)
  function m:on_obstacle_reached()
    if enemy:get_distance(map:get_hero()) <= 400 and enemy:is_in_same_region(map:get_hero()) then
      sol.audio.play_sound"clank"
      sol.audio.play_sound"thunk1"
    end
    enemy:stop_movement()
    sol.timer.start(enemy, 600, function()
      local dir = sprite:get_direction() + 1
      if dir >= 4 then dir = 0 end
      sprite:set_direction(dir)
      enemy:on_restarted()
    end)
  end
end

