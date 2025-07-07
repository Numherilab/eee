-- Provides additional camera features for this quest.

local camera_meta = sol.main.get_metatable("camera")


function camera_meta:shake(config, callback)
	local camera = self
	local camera_surface = camera:get_surface()

	local amplitude = config and config.amplitude or 3
	local speed = config and config.speed or 50
	local zoom_scale = config and config.zoom_scale or 1.02
	local shake_count = config and config.shake_count or 8
	if (shake_count % 2) == 0 then shake_count = shake_count + 1 end

	--zoom
	local cam_wid, cam_hig = camera:get_size()
	camera_surface:set_transformation_origin(cam_wid / 2, cam_hig / 2)
	local dx = {[1] = 1, [0] = zoom_scale}
	local dy = {[1] = 1, [0] = zoom_scale}
	local i = 1
	sol.timer.start(camera, 1, function()
	    camera_surface:set_scale(dx[i % 2], dy[i % 2])
	    if i <= shake_count * 1.5 then
	      i = i + 1
	      return 15
	    else
	      camera_surface:set_scale(1, 1)
	    end
	end)

	--shake
	local j = 1
	local shaking_right = true
	sol.timer.start(camera, 0, function()
		if j <= shake_count then
			local dir_mod = 1
			if not shaking_right then dir_mod = -1 end
			camera_surface:set_xy(amplitude * dir_mod, 0)
			shaking_right = not shaking_right
			j = j + 1
			return 1000 / speed
		else
      camera_surface:set_xy(0,0)
      if callback then callback() end
		end
	end)
end

-- Set the camera to a 4:3 aspect ratio for this map.
-- Useful as a fallback for old maps that need this.
function camera_meta:letterbox()
  self:set_size(320, 240)
  self:set_position_on_screen(48, 0)
end


function camera_meta:scroll_to_hero()
  local camera = self
  local map = camera:get_map()
  local hero = map:get_hero()
  m = sol.movement.create("target")
  m:set_ignore_obstacles(true)
  m:set_target(camera:get_position_to_track(hero))
  m:set_speed(180)
  m:start(camera, function() camera:start_tracking(hero) end)
end

return true
