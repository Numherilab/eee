--TEMP item, using it to rewrite ball_and_chain 

require("scripts/multi_events")

local item = ...
local game = item:get_game()

local NUM_LINKS = 9
local MIN_RADIUS = 2
local RADIUS = 48
local RAIUS_SPEED = 250
local MAX_ROTATIONS = 3
local ANGULAR_SPEED = 13
local CHARGING_TIME = 500


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
  item.summoning_state = summoning_state --for access in other functions
  local starting_health = game:get_life() --check health at beginning to cancel attack if hurt during charge

  hero:set_animation("charging")
  sol.timer.start(game, CHARGING_TIME, function()
    if game:get_life() == starting_health and hero:get_state_object() == summoning_state then
      item:swing()
    else
      item:set_finished()
    end
  end)
end)



function item:swing()
  local game = item:get_game()
  local map = item:get_map()
  local hero = map:get_hero()
  local x, y, layer = hero:get_position()
  local direction = hero:get_direction()
  local dx = {[0] = 16, [1] = 0, [2] = -16, [3] = 4}
  local dy = {[0] = -4, [1] = -16, [2] = -4, [3] = 10}

  local center_x = x + dx[direction]
  local center_y = y + dy[direction]


  --create chain links
  local links = {}
  local link_movements = {}
  for i=1, NUM_LINKS do
    links[i] = map:create_custom_entity{
      name = "flail_chain_link", layer = layer, x = center_x, y = center_y,
      width = 8, height = 8, direction = 0,
      sprite = "entities/chain_link",
      model = "damaging_sparkle"
    }
    links[i]:set_drawn_in_y_order(true)
    link_movements[i] = sol.movement.create("circle")
    link_movements[i]:set_center(center_x, center_y)
    link_movements[i]:set_ignore_obstacles()
    link_movements[i]:set_radius(MIN_RADIUS)
    link_movements[i]:set_radius_speed(RAIUS_SPEED)
    link_movements[i]:set_max_rotations(MAX_ROTATIONS)
    link_movements[i]:set_angular_speed(ANGULAR_SPEED)
    if hero_dir == 0 or hero_dir == 3 then link_movements[i]:set_clockwise() end
    links[i]:set_is_flail(true)
  end

  local arm_mask = map:create_custom_entity{
    x=x, y=y, layer=layer+1, width=16, height=32,direction=direction,
    sprite="hero/hookshot_arm_mask",
  }

  --create spike ball
  local spike_ball = map:create_custom_entity{
    name = "flail_spike_ball",
    x=center_x, y=center_y, layer=layer,
    width=8, height=8, direction=0,
    sprite = "entities/spike_ball",
    model = "damaging_sparkle",
  }
  spike_ball:set_drawn_in_y_order(true)
  spike_ball:set_damage(game:get_value("sword_damage") + game:get_value("sword_damage")/2)
  spike_ball:set_is_flail(true) --set_is_flail() is a method of damaging_sparkle entity

  --create a movement for the ball
  local m = sol.movement.create("circle")
  m:set_center(center_x, center_y)
  m:set_ignore_obstacles()
  if item:get_variant() >= 2 then m:set_ignore_obstacles(false) end
--  m:set_angle_from_center(start_angle)
  m:set_radius(MIN_RADIUS)
  m:set_radius_speed(RAIUS_SPEED)
  m:set_max_rotations(MAX_ROTATIONS)
  m:set_angular_speed(ANGULAR_SPEED)
  if hero_dir == 0 or hero_dir == 3 then m:set_clockwise() end
  link_movements[0] = m


  --ATTACK!
  --play sound
  local circling = true
  sol.timer.start(map, 2, function()
    if circling then
      sol.audio.play_sound("flail_swing")
      return 450
    end
  end)

  --Start the movements and change the hero's animation
  hero:set_animation("hookshot")
  m:start(spike_ball, function()
    spike_ball:remove()
    arm_mask:remove()
    hero:unfreeze()
    circling = false
  end)
  m:set_radius(RADIUS) --set radius after start to extend TO radius
  for i=1, NUM_LINKS do
    link_movements[i]:start(links[i], function() links[i]:remove() end)
    link_movements[i]:set_radius(RADIUS / NUM_LINKS * i)
  end

  --Update center position
  sol.timer.start(spike_ball, 10, function()
    x, y, layer = hero:get_position()
    center_x = x + dx[direction]
    center_y = y + dy[direction]
    for i=0, NUM_LINKS do
      link_movements[i]:set_center(center_x, center_y)
    end
    return true
  end)

  --end the movement if it doesn't collide with something
  function m:on_finished()
    hero:unfreeze()
    circling = false
    spike_ball:remove()
    arm_mask:remove()
    for i=1, NUM_LINKS do links[i]:remove() end
    item:set_finished()
  end

  --if the movement collides with something
  local can_play_sound = true
  local can_play_explosion_sound = true
  function m:on_obstacle_reached()
    if can_play_sound then
      sol.audio.play_sound("sword_tapping")
      can_play_sound = false
      sol.timer.start(game, 500, function() can_play_sound = true end)
    end

    --to cause a fucking explosion if the variant is 2 or more
    if item:get_variant() >= 2 then
      local spike_x, spike_y, spike_layer = spike_ball:get_position()
      map:create_explosion{layer = spike_layer, x = spike_x, y = spike_y}
      if can_play_explosion_sound then
        sol.audio.play_sound"explosion"
        can_play_explosion_sound = false
        sol.timer.start(game, 100, function() can_play_explosion_sound = true end)
      end
    end
  end

  --special check in case hero falls down hole while flail is swinging (edge case)
  sol.timer.start(spike_ball, 100, function()
    if hero:get_state_object() ~= item.summoning_state then
      spike_ball:remove()
      arm_mask:remove()
      for i=1, NUM_LINKS do
        links[i]:remove()
        circling = false
      end
    end
    return true
  end)

  --If the ball and chain are still somehow on the map via some edge case, let's get rid of them
  sol.timer.start(map, 7000, function()
    if spike_ball:exists() then spike_ball:remove() end
    for i=1, NUM_LINKS do
      if links[i]:exists() then links[i]:remove() end
    end
  end)

end






-- require("scripts/multi_events")

-- local item = ...
-- local game = item:get_game()

-- local NUM_LINKS = 7
-- local MIN_RADIUS = 2
-- local RADIUS = 48
-- local RAIUS_SPEED = 250
-- local MAX_ROTATIONS = 3
-- local ANGULAR_SPEED = 13
-- local CHARGING_TIME = 500


-- -- Event called when the game is initialized.
-- item:register_event("on_started", function(self)
--   item:set_savegame_variable("possession_ball_and_chain")
--   item:set_assignable(true)
-- end)

-- -- Event called when the hero is using this item.
-- item:register_event("on_using", function(self)
--   local map = item:get_map()
--   local hero = map:get_hero()
--   local hero_dir = hero:get_direction()
-- --  hero:freeze()
--   local summoning_state = sol.state.create()
--   summoning_state:set_can_control_movement(false)
--   summoning_state:set_can_be_hurt(true)
--   summoning_state:set_can_use_sword(false)
--   summoning_state:set_can_use_item(false)
--   summoning_state:set_can_interact(false)
--   summoning_state:set_can_grab(false)
--   summoning_state:set_can_pick_treasure(false)
--   hero:start_state(summoning_state)

--   local x, y, layer = hero:get_position()
--   local links = {}
--   local link_movements = {}
  
--   --now move x or y depending on hero facing direction
--   local start_x = x
--   local start_y = y
--   if hero_dir == 0 then start_x = x - 16 elseif hero_dir == 1 then start_y = y + 16 elseif hero_dir == 2 then start_x = x + 16 elseif hero_dir == 3 then start_y = y - 16 end

--   local flail_x = x
--   local flail_y = y
--   local start_angle = 0
--   if hero_dir == 0 then flail_x = x + 16 start_angle = 0
--   elseif hero_dir == 1 then
--     flail_y = y - 16
--     start_angle = math.pi / 2
--   elseif hero_dir == 2 then
--     flail_x = x - 16
--     start_angle = math.pi
--   elseif hero_dir == 3 then
--     flail_y = y + 16
--     start_angle = 3 * math.pi / 2
--   end

--   --create chain links
--   for i=1, NUM_LINKS do
--     links[i] = map:create_custom_entity{
--       name = "flail_chain_link",
--       direction = 0,
--       layer = layer,
--       x = start_x,
--       y = start_y,
--       width = 8,
--       height = 8,
--       sprite = "entities/chain_link",
--       model = "damaging_sparkle"
--     }
--     link_movements[i] = sol.movement.create("circle")
--     link_movements[i]:set_center(flail_x, flail_y)
--     link_movements[i]:set_ignore_obstacles()
--     link_movements[i]:set_radius(MIN_RADIUS)
--     link_movements[i]:set_radius_speed(RAIUS_SPEED)
--     link_movements[i]:set_max_rotations(MAX_ROTATIONS)
--     link_movements[i]:set_angular_speed(ANGULAR_SPEED)
--     if hero_dir == 0 or hero_dir == 3 then link_movements[i]:set_clockwise() end
--     links[i]:set_is_flail(true)
--   end

--   --create the spike ball
--   local spike_ball = map:create_custom_entity{
--     name = "flail_spike_ball",
--     direction = 0,
--     layer = layer,
--     x = start_x,
--     y = start_y,
--     width = 8,
--     height = 8,
--     sprite = "entities/spike_ball",
--     model = "damaging_sparkle"
--   }
--   spike_ball:set_damage(game:get_value("sword_damage") + game:get_value("sword_damage")/2)
--   spike_ball:set_is_flail(true)


--   --create a movement for the flail
--   local m = sol.movement.create("circle")
--   m:set_center(flail_x, flail_y)
--   m:set_ignore_obstacles()
--   if item:get_variant() >= 2 then m:set_ignore_obstacles(false) end
-- --  m:set_angle_from_center(start_angle)
--   m:set_radius(MIN_RADIUS)
--   m:set_radius_speed(RAIUS_SPEED)
--   m:set_max_rotations(MAX_ROTATIONS)
--   m:set_angular_speed(ANGULAR_SPEED)
--   if hero_dir == 0 or hero_dir == 3 then m:set_clockwise() end



--   --START CHARGING (because this is too powerful to not charge)
--   hero:set_animation("charging")
--   sol.timer.start(game, CHARGING_TIME, function()
--     --AND GO! ATTACK!
--     local circling = true
--     sol.timer.start(map, 2, function()
--       if circling then
--         sol.audio.play_sound("flail_swing")
--         return 450
--       end
--     end)
--     --Start the movements and change the hero's animation
--     hero:set_animation("hookshot")
--     m:start(spike_ball, function() spike_ball:remove() hero:unfreeze() circling = false end)
--     for i=1, NUM_LINKS do
--       link_movements[i]:start(links[i], function() links[i]:remove() end)
--       link_movements[i]:set_radius(RADIUS / NUM_LINKS * i)
--     end
--     m:set_radius(RADIUS)
--   end)


--   --end the movement if it doesn't collide with something
--   function m:on_finished()
--     hero:unfreeze()
--     circling = false
--     spike_ball:remove()
--     for i=1, NUM_LINKS do links[i]:remove() end
--     item:set_finished()
--   end

--   --if the movement collides with something
--   local can_play_sound = true
--   local can_play_explosion_sound = true
--   function m:on_obstacle_reached()
--     if can_play_sound then
--       sol.audio.play_sound("sword_tapping")
--       can_play_sound = false
--       sol.timer.start(game, 500, function() can_play_sound = true end)
--     end

--     --to cause a fucking explosion if the variant is 2 or more
--     if item:get_variant() >= 2 then
--       local spike_x, spike_y, spike_layer = spike_ball:get_position()
--       map:create_explosion{layer = spike_layer, x = spike_x, y = spike_y}
--       if can_play_explosion_sound then
--         sol.audio.play_sound"explosion"
--         can_play_explosion_sound = false
--         sol.timer.start(game, 100, function() can_play_explosion_sound = true end)
--       end
--     end
--   end
-- end)
