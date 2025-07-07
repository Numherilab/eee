require("scripts/multi_events")

local item = ...
local game = item:get_game()

--WHAT IS THIS? WHY DID I MAKE IT? WHAT'S THE DIFFERENCE BETWEEN THE OTHER BALL AND CHAIN!?!?!?

-- Event called when the game is initialized.
item:register_event("on_started", function(self)
  item:set_savegame_variable("possession_ball_and_chain")
  item:set_assignable(true)
end)

-- Event called when the hero is using this item.
item:register_event("on_using", function(self)
  local map = item:get_map()
  local hero = map:get_hero()
  local hero_dir = hero:get_direction()
--  hero:freeze()
  local summoning_state = sol.state.create()
  summoning_state:set_can_control_movement(false)
  summoning_state:set_can_be_hurt(true)
  summoning_state:set_can_use_sword(false)
  summoning_state:set_can_use_item(false)
  summoning_state:set_can_interact(false)
  summoning_state:set_can_grab(false)
  summoning_state:set_can_pick_treasure(false)
  hero:start_state(summoning_state)

  local x, y, layer = hero:get_position()
  local MIN_RADIUS = 2
  local RADIUS = 56
  local RAIUS_SPEED = 250
  local MAX_ROTATIONS = 3
  local ANGULAR_SPEED = 13
  local CHARGING_TIME = 500
  
  --now move x or y depending on hero facing direction
  local start_x = x
  local start_y = y
  if hero_dir == 0 then start_x = x - 16 elseif hero_dir == 1 then start_y = y + 16 elseif hero_dir == 2 then start_x = x + 16 elseif hero_dir == 3 then start_y = y - 16 end

  --create chain links
  local link1 = map:create_custom_entity{
    direction = 0,
    layer = layer,
    x = start_x,
    y = start_y,
    width = 8,
    height = 8,
    sprite = "entities/chain_link",
    model = "chain_link"
  }
  local link2 = map:create_custom_entity{
    direction = 0,
    layer = layer,
    x = start_x,
    y = start_y,
    width = 8,
    height = 8,
    sprite = "entities/chain_link",
    model = "chain_link"
  }
  --create the spike ball
  local spike_ball = map:create_custom_entity{
    name = "spike_ball",
    direction = 0,
    layer = layer,
    x = start_x,
    y = start_y,
    width = 16,
    height = 16,
    sprite = "entities/spike_ball",
    model = "damaging_sparkle"
  }
  spike_ball:set_damage(game:get_value("sword_damage") + game:get_value("sword_damage")/2)

  local flail_x = x
  local flail_y = y
  local start_angle = 0
  if hero_dir == 0 then flail_x = x + 16 start_angle = 0
  elseif hero_dir == 1 then flail_y = y - 16 start_angle = math.pi / 2
  elseif hero_dir == 2 then flail_x = x - 16 start_angle = math.pi
  elseif hero_dir == 3 then flail_y = y + 16 end start_angle = 3 * math.pi / 2

  --create a movement for the flail
  local m = sol.movement.create("circle")
  m:set_center(flail_x, flail_y)
--  m:set_angle_from_center(start_angle)
  m:set_radius(MIN_RADIUS)
  m:set_radius_speed(RAIUS_SPEED)
  m:set_max_rotations(MAX_ROTATIONS)
  m:set_angular_speed(ANGULAR_SPEED)
  if hero_dir == 0 or hero_dir == 3 then m:set_clockwise() end

  local m2 = sol.movement.create("circle")
  m2:set_center(flail_x, flail_y)
--  m:set_angle_from_center(start_angle)
  m2:set_radius(MIN_RADIUS)
  m2:set_radius_speed(RAIUS_SPEED)
  m2:set_max_rotations(MAX_ROTATIONS)
  m2:set_angular_speed(ANGULAR_SPEED)
  if hero_dir == 0 or hero_dir == 3 then m2:set_clockwise() end

  local m3 = sol.movement.create("circle")
  m3:set_center(flail_x, flail_y)
--  m:set_angle_from_center(start_angle)
  m3:set_radius(MIN_RADIUS)
  m3:set_radius_speed(RAIUS_SPEED)
  m3:set_max_rotations(MAX_ROTATIONS)
  m3:set_angular_speed(ANGULAR_SPEED)
  if hero_dir == 0 or hero_dir == 3 then m3:set_clockwise() end


  --START CHARGING (because this is too powerful to not charge)
  hero:set_animation("charging")
  sol.timer.start(game, CHARGING_TIME, function()
    --AND GO! ATTACK!
    --Start the movements and change the hero's animation
    hero:set_animation("hookshot")
    sol.audio.play_sound("boomerang")
    m:start(spike_ball, function() spike_ball:remove() hero:unfreeze() end)
    m2:start(link1, function() link1:remove() end)
    m3:start(link2, function() link2:remove() end)
    m:set_radius(RADIUS)
    m2:set_radius(RADIUS / 3 * 2)
    m3:set_radius(RADIUS / 3)
  end)


  --end the movement if it doesn't collide with something
  function m:on_finished()
    hero:unfreeze()
    spike_ball:remove()
    link1:remove()
    link2:remove()
    item:set_finished()
  end

  --if the movement collides with something
  function m:on_obstacle_reached()
    spike_ball:get_sprite():set_animation("sparking")
    sol.audio.play_sound("sword_tapping")

    --these commented out lines would cause an explosion if the flail contacts something.
    --I'm saving them because that's kinda sick.
    if item:get_variant() >= 2 then
      local spike_x, spike_y, spike_layer = spike_ball:get_position()
      map:create_explosion{layer = spike_layer, x = spike_x, y = spike_y}
    end
  end
end)
