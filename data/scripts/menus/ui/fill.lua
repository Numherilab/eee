--[[ fill.lua
	version 1.0
	15 Dec 2018
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/
	
	This script creates an ui subcomponent used to draw a solid fill color region that may
	use opacity onto a destination surface. The width and height of the region to be drawn
	is fixed.
]]

local util = require"scripts/menus/ui/util"

local control = {}

--// Creates a new fill control
	--properties (table) - table containing properties defining fill behavior
		--color (string or table) - color of the fill
			--see make_RGB_color() in scripts/menus/ui/util.lua for more info
	--width (number or nil) - width of the fill region in pixels
		--nil - uses the entire width of the destination surface
	--height (number or nil) - height of the fill region in pixels
		--nil - uses the entire height of the destination surface
	--returns the newly created fill object (table)
function control.create(properties, width, height)
	local new_control = {}
	
	--settings defined by data file property values and their default values
	local width = width --(number, positive integer) max width of component in pixels, if nil then fills entire destination surface
	local height = height --(number, positive integer) max height of component in pixels, if nil then fills entire destination surface
	local color --(table, array) RGB color of text when enabled
	
	--additional settings
	local position = {x=0, y=0} --(table, key/value) movements change the coordinates of this table, which are added as an offset to the component position when drawn
		--x (number, integer) - amount of the horizontal offset in pixels
		--y (number, integer) - amount of the vertical offset in pixels
		--movement (sol.movement or nil) - active movement of the component, if nil then the movement is done
	local is_visible = true --(boolean) component is not drawn if false, default: true
	
	
	--// validate data file property values
	
	assert(type(properties)=="table", "Bad argument #1 to 'create' (table expected)")
	
	--validate width
	if width then
		width = tonumber(width)
		assert(width, "Bad argument #2 to 'create' (number or nil expected)")
		width = math.floor(width)
		assert(width>0, "Bad argument #2 to 'create' (number must be positive)")
	end
	
	--validate height
	if height then
		height = tonumber(height)
		assert(height, "Bad argument #3 to 'create' (number or nil expected)")
		height = math.floor(height)
		assert(height>0, "Bad argument #3 to 'create' (number must be positive)")
	end
	
	--validate color
	local err --temporary error message
	color, err = util.make_RGB_color(properties.color)
	assert(color, "Bad property color to 'create'"..tostring(err or ''))
	
	
	--// implementation
	
	--// Returns the width and height (number) of the fill region in pixels
		--a value of nil indicates to use the entire width/height, respectively
	function new_control:get_size() return width, height end
	
	--// Get/set the color of the fill region as 3 RGB or 4 RGBA values, 0 to 255
	function new_control:get_color() return util.make_RGB_color(color) end --returns a copy of color table
	function new_control:set_color(value)
		local value, err = util.make_RGB_color(value)
		assert(value, "Bad argument #2 to 'set_color'"..tostring(err or ''))
		
		color = value
	end
	
	--// Get/set whether the fill is visible (visible by default)
		--value (boolean) - if true then the fill is visible
	function new_control:get_visible() return is_visible end
	function new_control:set_visible(value)
		assert(type(value)=="boolean", "Bad argument #2 to 'set_visible' (boolean expected)")
		is_visible = value
	end
	
	--// Get/set the x & y offset that is added to the position of where the component is drawn
	function new_control:get_xy() return position.x, position.y end
	function new_control:set_xy(x, y)
		local x = tonumber(x)
		assert(x, "Bad argument #2 to 'set_xy' (number expected)")
		
		local y = tonumber(y)
		assert(y, "Bad argument #3 to 'set_xy' (number expected)")
		
		position.x = x
		position.y = y
	end
	
	--// Get the current movement of the text component
	function new_control:get_movement() return position.movement end
	
	--// Assign a movement to the component and start it
		--movement (sol.movement) - movement to apply to the component
		--callback (function, optional) - function to be called once the movement has finished
	function new_control:start_movement(movement, callback)
		position.movement = movement --save reference to active movement
		movement:start(position, function(...)
			position.movement = nil --remove reference once movement is done
			callback(...)
		end)
	end
	
	--// Stop the current movement of the component if it exists
	function new_control:stop_movement()
		local movement = position.movement --convenience
		if movement then
			movement:stop()
			position.movement = nil
		end
	end
	
	--// Draws the fill on the specified destination surface
		--dst_surface (sol.surface) - surface on which to draw the fill
		--x (number, optional) - x coordinate of where to draw the fill
		--y (number, optional) - y coordinate of where to draw the fill
	function new_control:draw(dst_surface, x, y)
		if is_visible then
			if width then
				local x = x + position.x
				local y = y + position.y
				
				dst_surface:fill_color(color, x, y, width, height)
			else dst_surface:fill_color(color) end
		end
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
