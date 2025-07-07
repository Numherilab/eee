-- Lua script of map isle_of_storms/test.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()


local white_surface = sol.surface.create()
  white_surface:fill_color({255,255,255})
  white_surface:set_opacity(255)
local camera_surface = map:get_camera():get_surface()


local fog = sol.surface.create("fog/big_water_light.png")
fog:set_blend_mode("blend")
fog:set_opacity(25)
local fog2 = sol.surface.create("fog/big_water_dark.png")
fog2:set_blend_mode("multiply")
fog2:set_opacity(25)
fog2:set_xy(-500,-200)
local fog3 = sol.surface.create("fog/water_squiggles.png")
fog3:set_blend_mode("blend")
fog3:set_opacity(30)
fog3:set_xy(-400,-240)

  function move_fog(fog, angle, distance)
    local m = sol.movement.create("straight")
    m:set_angle(angle)
    m:set_speed(20)
    m:set_max_distance(distance)
    m:start(fog, function() move_fog(fog, angle + math.pi, distance) end)
  end
move_fog(fog, 3, 200)
move_fog(fog2, .3, 350)
move_fog(fog3, -2.2, 250)


function map:on_draw(dst_surface)
  white_surface:draw(dst_surface)
  fog:draw(map:get_camera():get_surface())
  fog2:draw(map:get_camera():get_surface())
  fog3:draw(map:get_camera():get_surface())
end

function map:on_started()


end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
map:register_event("on_opening_transition_finished", function()
  white_surface:fade_out(100)
  fog2:fade_in(100)
end)
