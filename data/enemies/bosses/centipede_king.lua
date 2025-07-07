local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local segments = {}
local position_buffer = {}
--local buffer_size = 1

local NUM_SEGMENTS = 8 --this includes the head
local SPACING = 18
local MAX_BUFFER_SIZE = NUM_SEGMENTS * SPACING
local SPEED = 65


function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:set_consequence_for_all_attacks("protected")
  --the head is segment 1
  segments[1] = enemy
  --create legs
  for i=2, NUM_SEGMENTS do
    segments[i] = enemy:create_enemy{
      name = "leg "..i,
      breed = "bosses/centipede_king_legs"
    }
    segments[i]:set_consequence_for_all_attacks("protected")
  end
  --in case legs are destroyed before head
  for i=2, NUM_SEGMENTS do
    local leg = segments[i]
    function leg:on_dead()
      table.remove(segments, i)
      SPEED = SPEED + 8
      enemy:on_restarted()
    end
    function leg:on_restarted()
      if leg.vulnerable == true then leg:get_sprite():set_animation("vulnerable") end
    end
  end
end


function enemy:on_movement_changed()
  local direction = enemy:get_movement():get_direction4()
  enemy:get_sprite():set_direction(direction)  
end


function enemy:on_restarted()
  --set last segment as vulnerable
  segments[#segments]:set_default_attack_consequences()
  segments[#segments].vulnerable = true
  segments[#segments]:get_sprite():set_animation("vulnerable")

  --move head
  local direction = (math.random(1, 4))*math.pi/2
  local movement = sol.movement.create("straight")
  movement:set_angle(direction)
  movement:set_speed(SPEED)
  movement:start(enemy)

  --on collision with wall
  function movement:on_obstacle_reached()
    movement:set_angle(math.random(1, 4) * math.pi / 2)
    movement:start(enemy)
  end

  --random juke
  sol.timer.start(enemy, math.random(800, 3000), function()
    movement:set_angle(math.random(1, 4) * math.pi / 2)
    movement:start(enemy)
    return math.random(1500, 5000)
  end)

end


enemy:register_event("on_dead", function()
  for i = 2, NUM_SEGMENTS + 1 do
    if segments[i] then
      segments[i]:hurt(200)
    end
  end
end)

function enemy:on_position_changed(x, y, layer)
  --save head's position
  local dir = enemy:get_sprite():get_direction()
  table.insert(position_buffer, 1, {x=x,y=y,layer=l,direction=dir})
  --move legs
  for i=2, NUM_SEGMENTS do
    local step_delay = SPACING * (i-1)
    if #position_buffer >= step_delay and segments[i] then
      segments[i]:set_position(position_buffer[step_delay].x, position_buffer[step_delay].y)
    end
  end
  if #position_buffer > MAX_BUFFER_SIZE then
    table.remove(position_buffer)
  end
end