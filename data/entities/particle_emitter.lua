local emitter = ...
local game = emitter:get_game()
local map = emitter:get_map()

local particles = {}
local sprite

local emission_rate = 200
local direction = math.pi/2
local spread = math.rad(90)
local particle_duration = 2999
local particle_speed = 20
local sprite_type = "entities/moth"
local originx, originy, originz

function emitter:set_rate(new_rate)
  rate = new_rate
end

function emitter:set_direction(dir)
  direction = dir
end

--Enter spread in degrees because my brain doesn't comprehend radians in increments other than 90 degrees)
function emitter:set_spread(spr)
  spread = math.rad(spr)
end

function emitter:get_particles_array()
  return particles
end


function emitter:on_created()
  sprite = sol.sprite.create(sprite_type)
  originx, originy, originz = emitter:get_position()

  sol.timer.start(emitter, emission_rate, function()
    emitter:emit_new_particle()
    return true
  end)

  sol.timer.start(emitter, 1000/particle_speed, function()
    for i=1, #particles do
      particles[i].x = 1 * math.cos(particles[i].angle) + particles[i].x
      particles[i].y = 1 * math.sin(particles[i].angle) + particles[i].y
    end
    return true
  end)

end

function emitter:emit_new_particle()
 local i = #particles + 1 or 1
 particles[i] = sprite
 particles[i].x = originx
 particles[i].y = originy
 particles[i].angle = direction + spread/2 - math.random() * spread
end

function emitter:on_post_draw(camera)
  local dst = camera:get_surface()
  for i=1, #particles do
    if particles[i] then map:draw_visual(particles[i], particles[i].x, particles[i].y) end
  end
end
