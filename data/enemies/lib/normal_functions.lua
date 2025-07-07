--This script sets up the things you want every enemy to have. Changing the sprite on change in movement direction, etc.

local normal_functions = {}


function normal_functions:initialize(enemy, properties)

  local game = enemy:get_game()
  local map = enemy:get_map()
  local hero = map:get_hero()


  local circling = false

  -- function enemy:on_obstacle_reached(movement)
  --   if not going_hero then
  --     enemy:go_random()
  --     enemy:check_hero()
  --   end
  -- end

  --align the sprite with movement direction.
  function enemy:on_movement_changed(movement)
    local direction4 = movement:get_direction4()
    local sprite = self:get_sprite()
    sprite:set_direction(direction4)

    -- local ground = self:get_ground_below()
    -- if self.grass_sprite == nil and ground == "grass" then
    --   self.grass_sprite = self:create_sprite("enemies/ground1")
    -- elseif self.grass_sprite and ground ~= "grass" then
    --   self:remove_sprite(self.grass_sprite)
    --   self.grass_sprite = nil
    -- end

  end

  function enemy:on_position_changed()
    local ground = self:get_ground_below()
    if self.grass_sprite == nil and ground == "grass" then
      self.grass_sprite = self:create_sprite("enemies/ground1")
    elseif self.grass_sprite and ground ~= "grass" then
      self:remove_sprite(self.grass_sprite)
      self.grass_sprite = nil
    end
  end

  --determine if enemy is near hero
  function enemy:is_near_hero()
    local layer = self:get_layer()
    local hero_layer = hero:get_layer()
    local dist_hero = self:get_distance(hero)
    local near_hero = (layer == hero_layer or enemy:has_layer_independent_collisions())
      and dist_hero <= properties.detection_distance and self:is_in_same_region(hero)
    return near_hero
  end
  

  --wander aimlessly
  function enemy:go_random()
    going_hero = false
    circling = false
    local m = properties.movement_create() --check to see what type of movement is in properties, random path is default
    if m == nil then --if not, stop the animation first
      self:get_sprite():set_animation("stopped")
      m = self:get_movement() --see if we're already moving
      if m ~= nil then
        -- Stop the previous movement.
        m:stop()
      end
    else
      m:set_speed(properties.normal_speed)
      m:set_ignore_obstacles(properties.ignore_obstacles)
      m:start(self)
      if self:get_sprite():has_animation"walking" then
        self:get_sprite():set_animation("walking")
      end
    end
  end

  --head toward the hero
  function enemy:go_hero()
    if properties.movement_circle_hero and enemy:has_nearby_allies() then
      enemy:start_circling()
    else
      enemy:pursue_hero()
    end
  end


  function enemy:pursue_hero()
    circling = false
    local m = sol.movement.create("target")
    m:set_speed(properties.faster_speed)
    m:set_ignore_obstacles(properties.ignore_obstacles)
    m:start(self)
    self:get_sprite():set_animation("walking")
  end


  function enemy:start_circling()
    circling = true
    local x, y, layer = enemy:get_position()
    local beacon = map:create_custom_entity({
      x = x, y = y, layer = layer, direction = 0, height = 8, width = 8
    })
    beacon:set_can_traverse(true)
    beacon:set_can_traverse_ground("empty", true)
    beacon:set_can_traverse_ground("wall", true)
    beacon:set_can_traverse_ground("low_wall", true)
    beacon:set_can_traverse_ground("deep_water", true)
    beacon:set_can_traverse_ground("shallow_water", true)
    beacon:set_can_traverse_ground("hole", true)
    beacon:set_can_traverse_ground("ladder", true)
    beacon:set_can_traverse_ground("lava", true)
    beacon:set_can_traverse_ground("prickles", true)
    local m = sol.movement.create("circle")
    m:set_ignore_obstacles(properties.ignore_obstacles)
    m:set_center(hero)
    local angle_from_center = self:get_angle(hero)
    m:set_angle_from_center(angle_from_center + math.pi)
    m:set_radius(properties.movement_circle_hero_radius)
    m:set_radius_speed(properties.movement_circle_hero_radius_speed)
    m:set_angular_speed(2*math.pi / 6)
    m:start(beacon)

    sol.timer.start(map, 10000, function() beacon:remove() end)

    local m2 = sol.movement.create("target")
    m2:set_target(beacon)
    m2:set_smooth(true)
    m2:set_speed(properties.faster_speed)
    m2:start(self)
    self:get_sprite():set_animation("walking")
  end

  function enemy:check_to_break_circle()
    if circling and not enemy:has_nearby_allies() then
      enemy:pursue_hero()
    end
  end


  function enemy:has_nearby_allies()
    for entity in map:get_entities_by_type("enemy") do
        if enemy:get_position() ~= entity:get_position() and enemy:get_breed() == entity:get_breed()
        and enemy:get_distance(entity) < 100 and entity:get_life() > 0 then
          return true
        end
    end
  end

end

return normal_functions