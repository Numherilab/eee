--[[ sprite.lua
	version 1.0
	15 Dec 2018
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This script creates an ui subcomponent created from a sprite entity that is drawn onto
	a destination surface. It is possible for the sprite have multiple frames and animate.
]]

local util = require"scripts/menus/ui/util"

local control = {}

-- methods to inherit from sol.sprite
local SPRITE_METHODS = {
	get_animation = true,
	set_animation = true,
	has_animation = true,
	get_direction = true,
	set_direction = true,
	get_num_directions = true,
	get_frame = true,
	set_frame = true,
	get_num_frames = true,
	get_frame_delay = true,
	set_frame_delay = true,
	get_origin = true,
	is_paused = true,
	set_paused = true,
	set_ignore_suspend = true,
	synchronize = true,
	get_blend_mode = true,
	set_blend_mode = true,
	fade_in = true,
	fade_out = true,
	get_xy = true,
	set_xy = true,
	get_movement = true,
	stop_movement = true,
}

--// Creates a new image control
	--properties (table) - table containing properties defining image behavior
		--sprite (string) - id of the sprite to use
		--animation (string) - id of the animation for the sprite
	--returns the newly created image object (table)
function control.create(properties)
	local new_control = {}
	
	--settings defined by data file property values and their default values
	local sprite_id = properties.sprite --(string) animation set id of the sprite
	
	--additional settings
	local sprite --(sol.sprite) sprite that is drawn for this component
	local is_enabled = true --(boolean) determines animation of sprite, using "enabled" if true or "disabled" if false
	local is_visible = true --(boolean) component is not drawn if false, default: true
	
	
	--// validate data file property values
	
	assert(type(properties)=="table", "Bad argument #1 to 'create' (table expected)")
	
	--validate sprite_id
	assert(type(sprite_id)=="string", "Bad property sprite_id to 'create' (string expected)")
	sprite = sol.sprite.create(sprite_id)
	assert(sprite, "Error in 'create', sprite cannot be found: "..sprite_id)
	
	--validate animation_id
	local animation_id = properties.animation --convenience, only used temporarily during creation
	assert(not animation_id or type(animation_id)=="string", "Bad property animation_id to 'create' (string expected)")
	if animation_id then sprite:set_animation(animation_id) end
	animation_id = nil --no longer used
	
	
	--//implementation
	
	--inherit methods of sol.sprite
	setmetatable(new_control, { __index = function(self, name)
		if SPRITE_METHODS[name] then
			return function(_, ...) return sprite[name](sprite, ...) end
		else return function() end end
	end})
	
	--// Returns the width and height (number) of the image in pixels
	function new_control:get_size() return sprite:get_size() end
	
	--// Returns the path (string) of the source image file
	function new_control:get_sprite_id() return sprite_id end
	
	--// Get/set whether the image is visible (newly created images are visible by default)
		--value (boolean) - if true then the image is visible
	function new_control:get_visible() return is_visible end
	function new_control:set_visible(value)
		assert(type(value)=="boolean", "Bad argument #2 to 'set_visible' (boolean expected)")
		is_visible = value
	end
	
	--// Assign a movement to the component and start it
		--movement (sol.movement) - movement to apply to the component
		--callback (function, optional) - function to be called once the movement has finished
	function new_control:start_movement(movement, callback) movement:start(sprite, callback) end
	
	--// Draws the image on the specified destination surface
		--dst_surface (sol.surface) - surface on which to draw the image
		--x (number, optional) - x coordinate of where to draw the image
		--y (number, optional) - y coordinate of where to draw the image
	function new_control:draw(dst_surface, x, y)
		if is_visible then sprite:draw(dst_surface, x, y) end
	end
	
	return new_control
end

return control

--[[ Copyright 2016-2018 Llamazing
  [] 
  [] This program is free software: you can redistribute it and/or modify it under the
  [] terms of the GNU General Public License as published by the Free Software Foundation,
  [] either version 3 of the License, or (at your option) any later version.
  [] 
  [] It is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  [] without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
  [] PURPOSE.  See the GNU General Public License for more details.
  [] 
  [] You should have received a copy of the GNU General Public License along with this
  [] program.  If not, see <http://www.gnu.org/licenses/>.
  ]]
