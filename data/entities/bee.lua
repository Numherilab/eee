local bee = ...
local game = bee:get_game()
local map = bee:get_map()
local sprite
local SPEED = 40
local IDLE_FREQUENCY_MIN = 5000
local IDLE_FREQUENCY_MAX = 8000
local IDLE_LENGTH_MIN = 2000
local IDLE_LENGTH_MAX = 8000
local BONK_ODDS = 2 --odds out of 10 that the bee will bonk into something a second time
local SPRITE_ID = "entities/mock_bee" --must have animations: walking(loops), idle(loops), bonk(does not loop)

function bee:on_created()
  sprite = bee:create_sprite(SPRITE_ID)
  bee:start_movement()
end



function bee:start_movement()
  sprite:set_animation"walking"
  local m = sol.movement.create"random_path"
  m:set_speed(SPEED)
  m:start(bee)

  sol.timer.start(bee, math.random(IDLE_FREQUENCY_MIN, IDLE_FREQUENCY_MAX), function()
    bee:stop_movement()
    sprite:set_animation"idle"
    sol.timer.start(bee, math.random(IDLE_LENGTH_MIN, IDLE_LENGTH_MAX), function()
      bee:start_movement()
    end)
  end)

  function m:on_obstacle_reached()
    bee:bonk(m:get_angle())
  end

  function m:on_changed()
    sprite:set_direction(m:get_direction4())
  end

end

function bee:bonk(direction)
  sol.timer.stop_all(bee)
  sprite:set_animation("bonk", "walking")
  local m = sol.movement.create"straight"
  m:set_angle(direction + math.pi)
  m:set_max_distance(8)
  m:set_speed(200)
  m:start(bee, function()
    bee:stop_movement()
    --pause to get bearings
    sol.timer.start(bee, 2000, function()
      if BONK_ODDS >= math.random(1, 10) then
        --bonk again
        --there's already a natural chance the bee will bonk again because "random_path" movement might go the same way
        bee:start_movement()
      else
        bee:start_movement()
      end
    end)
  end)
end
