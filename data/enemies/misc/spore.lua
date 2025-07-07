local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local duration = 1000
local disperse_distance = 12

-- Event called when the enemy is initialized.
function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
--  sprite:set_blend_mode"add"
  sprite:set_frame(0, sprite:get_num_frames()-1)
  sprite:set_frame_delay(math.random(80,140))
  enemy:set_damage(1)
  enemy:set_invincible()
  enemy:set_attacking_collision_mode("overlapping")
end

function enemy:set_duration(new_dur)
  duration = new_dur
end

function enemy:set_disperse_distance(dist)
  disperse_distance = dist
end

function enemy:disperse()
--[
  local angle = math.random() * math.pi * 2
  local m = sol.movement.create("straight")
  m:set_speed(80)
  local max_dist = math.random(1,disperse_distance)
  m:set_max_distance(max_dist)
  m:set_angle(angle)
  m:set_ignore_obstacles()
  m:start(enemy, function()
    m = sol.movement.create"random"
    m:set_speed(10)
    m:start(enemy)
  end)
--]]
--[[
  local angle = math.random() * math.pi * 2
  local m = sol.movement.create"straight"
  m:set_speed(200)
  m:set_max_distance(8)
  m:set_angle(angle)
  m:set_ignore_obstacles()
  m:start(enemy)  
--]]
--For some reason this acceleration thing doesn't work, it breaks the max_distance of the movement:
--[[
  --modulate speed
  sol.timer.start(enemy, 10, function()
    m:set_speed(m:get_speed() - 10)
    if m:get_speed() > 40 then return true end
  end)
--]]
end


function enemy:on_restarted()
  sol.timer.start(enemy, math.random(duration-600, duration+200), function()
    sprite:fade_out(10, function() enemy:remove() end)
  end)
end
