local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local startx, starty, startl
enemy.immobilize_immunity = true

--[[
This enemy will spin around the x,y where its starting location is set

Properties you can set:
damage
speed (5 is default. Rad/sec)
clockwise (leaving it nil means the movement will be anticlockwise)
radius (64 is default)
--]]

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_obstacle_behavior("flying")
  startx, starty, startl = enemy:get_position()
  enemy:set_damage(2)
  if enemy:get_property("damage") then enemy:set_damage(enemy:get_property("damage")) end
  enemy:set_invincible(true)
end


function enemy:on_restarted()
  local m = sol.movement.create("circle")
  m:set_max_rotations(0) --infinite rotations
  m:set_ignore_obstacles()
  --Center
  m:set_center(startx, starty)


  --Speed
  if not enemy:get_property("speed") then
    m:set_angular_speed(5)
  else
    m:set_angular_speed(enemy:get_property("speed"))
  end
  --Clockwise
  if enemy:get_property("clockwise") then
    m:set_clockwise(true)
  end
  m:set_radius(1)

  m:start(enemy)

  --Radius
  if not enemy:get_property("radius") then
    m:set_radius(64)
  else
    m:set_radius(enemy:get_property("radius"))
  end

end
