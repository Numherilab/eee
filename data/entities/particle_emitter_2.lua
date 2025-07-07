local entity = ...
local game = entity:get_game()
local map = entity:get_map()

local max_particles = 1
local num_particles = 0
local speed = 40
local max_distance = 40
local angle = math.pi/2
local x, y = entity:get_position()

local function create_particles()
  local sparkle_sprite = sol.sprite.create("entities/moth")
  local particle_list, timers = {}, {}  
  local w, h = sol.video.get_quest_size()
  local particle_surface = sol.surface.create(w, h)
  
  for i = 0, max_particles - 1 do
    particle_list[i] = {index = i}
  end
  
  local function make_particle()
    -- Prepare next slot.
    local index, particle = 0, particle_list[0]
    while index < max_particles and particle.exists do
      index = index + 1
      particle = particle_list[index]
    end
    if particle == nil or particle.exists then return end
    -- Set properties for new drop.
    local cx, cy, cw, ch = map:get_camera():get_bounding_box()
    particle.init_x = x
    particle.init_y = y
	particle.opacity = 255
    particle.x, particle.y, particle.frame = 0, 0, 0
    particle.speed = math.random() + speed
    particle.angle = (math.random() + angle) * math.pi / 4
    particle.max_distance = math.random() + max_distance
    num_particles = num_particles + 1
    particle.exists = true
  end
  
  local function update_particle_surface()
    particle_surface:clear()
    local camera = map:get_camera()
    local cx, cy, cw, ch = camera:get_bounding_box()
	
    -- Draw particles on surface.
--    sparkle_sprite:set_animation("default")
    sparkle_sprite:set_opacity(255)
    
	for _, particle in pairs(particle_list) do
      if particle.exists then
        sparkle_sprite:set_frame(particle.frame)
        local x = (particle.init_x + particle.x - cx) % cw
        local y = (particle.init_y + particle.y - cy) % ch
		sparkle_sprite:set_opacity(particle.opacity)
        sparkle_sprite:draw(particle_surface, x, y)
      end
    end
  end
  
  local function start_particle()
    timers["particle_creation_timer"] = sol.timer.start(map, 10, function()
      make_particle()
      return true -- Repeat loop.
    end)

    if timers["particle_position_timer"] == nil then
      local dt = 10 -- Timer delay.
      timers["particle_position_timer"] = sol.timer.start(map, dt, function()
        for index, particle in pairs(particle_list) do
          if particle.exists then
            local distance_increment = speed * (dt / 1000)
            particle.x = particle.x + distance_increment * math.cos(angle)
            particle.y = particle.y + distance_increment * math.sin(angle) * (-1)
		
		   
			particle.opacity = 255
			
            local distance = math.sqrt((particle.x)^2 + (particle.y)^2)
            if distance >= max_distance then
              -- Disable drop and create drop splash.
              particle.exists = false
			  num_particles = num_particles - 1
            end
          end
        end
        return true
      end)
    end
  
    if timers["particle_frame_timer"] == nil then
      timers["particle_frame_timer"] = sol.timer.start(map, 75, function()
        for _, particle in pairs(particle_list) do
          if particle.exists then
            particle.frame = (particle.frame + 1) % 2
          end
        end
        return true
      end)
    end
  end
  start_particle()

  map:register_event("on_draw", function(_, dst_surface)
    if particle_surface and num_particles > 0 then
	  update_particle_surface()
	  particle_surface:draw(dst_surface)
   	end
  end)
end


function entity:on_created()
  create_particles()
end
