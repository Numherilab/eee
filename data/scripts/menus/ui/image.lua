--[[ image.lua
	version 1.0
	15 Dec 2018
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This script creates an ui subcomponent created from an image file that is drawn onto a
	destination surface. The image is static with fixed dimensions.
]]

local util = require"scripts/menus/ui/util"

local control = {}

--// Creates a new image control
	--properties (table) - table containing properties defining image behavior
		--image (string) - file path of the image to use
		--region_width (number, optional) - width in pixels of the image to draw
		--region_height (number, optional) - height in pixels of the image to draw
		--region_x (number, optional) - x coordinate of the region (default: 0)
		--region_y (number, optional) - y coordinate of the region (default: 0)
	--returns the newly created image object (table)
function control.create(properties)
	local new_control = {}
	
	--settings defined by data file property values and their default values
	local region_width = properties.region_width --(number, positive integer) width of region in source image to use as component image
	local region_height = properties.region_height --(number, positive integer) height of region in source image to use as component image
	local region_x = tonumber(properties.region_x or 0) --(number, non-negative integer) x coordinate of region in source image to use as component image
	local region_y = tonumber(properties.region_y or 0) --(number, non-negative integer) y coordinate of region in source image to use as component image
	local path = properties.image --(string) file path to use for source image relative to the sprites directory
	
	--additional settings
	local surface --(sol.surface) surface that contains the raw source image (may be shared with other image components, so don't modify it)
	local position = {x=0, y=0} --(table, key/value) movements change the coordinates of this table, which are added as an offset to the component position when drawn
		--x (number, integer) - amount of the horizontal offset in pixels
		--y (number, integer) - amount of the vertical offset in pixels
		--movement (sol.movement or nil) - active movement of the component, if nil then the movement is done
	local opacity = 255 --(number, non-negative integer) opacity of the component, 0 to 255 where 0 is transparent and 255 is opaque, initially opaque
	local is_visible = true --(boolean) component is not drawn if false, default: true
	
	--constants
	local width --(number, positive intger) width of the source image in pixels --TODO change the name since this is not the component width, perhaps source_width?
	local height --(number, positive integer) height of the source image in pixels --TODO change the name since this is not the component width, perhaps source_height?
	local num_columns --(number, positive integer) number of columns in source image, whose width is equal to region_width
	local num_rows --(number, positive integer) number of rows in the source image, whose height is equal to region_height
	local max_index --(number, positive integer) the maximum index for the source image, equal to num_columns*num_rows
	
	
	--// validate data file property values
	
	assert(type(properties)=="table", "Bad argument #1 to 'create' (table expected)")
	
	--validate region_width
	if region_width then
		region_width = tonumber(region_width)
		assert(region_width, "Bad property region_width to 'create' (number expected)")
		region_width = math.floor(region_width)
		assert(region_width>0, "Bad property region_width to 'create' (number must be positive)")
	end
	
	--validate region_height
	if region_height then
		region_height = tonumber(region_height)
		assert(region_height, "Bad property region_height to 'create' (number expected)")
		region_height = math.floor(region_height)
		assert(region_height>0, "Bad property region_height to 'create' (number must be positive)")
	end
	
	--validate region_x
	assert(region_x, "Bad property region_x to 'create' (number or nil expected)")
	region_x = math.floor(region_x)
	assert(region_x>=0, "Bad property region_x to 'create' (number must not be negative)")
	
	--validate region_y
	assert(region_y, "Bad property region_y to 'create' (number or nil expected)")
	region_y = math.floor(region_y)
	assert(region_y>=0, "Bad property region_y to 'create' (number must not be negative)")
	
	--validate path
	assert(type(path)=="string", "Bad property image to 'create' (string expected)")
	surface = util.get_image(path)
	assert(surface, "Error in 'create', image cannot be loaded: "..path)
	
	
	--// implementation
	
	--index calculations
	width, height = surface:get_size()
	num_columns = region_width and math.floor(width/region_width) or 1
	num_rows = region_height and math.floor(height/region_height) or 1
	max_index = num_columns*num_rows
	
	--// Returns the width and height (number) of the image in pixels
	function new_control:get_size() return region_width, region_height end
	
	--// Returns the path (string) of the source image file
	function new_control:get_image_path() return path end
	
	--// Adjusts region_x & region_y values based on specified index value
	function new_control:set_index(value)
		local index = tonumber(value)
		assert(index, "Bad argument #2 to 'set_index' (number expected)")
		index = math.min(math.max(math.floor(index), 1), max_index) - 1 --convert to zero-based
		
		local y = math.floor((index)/num_columns)
		local x = index-y*num_columns
		
		region_x = x*region_width
		region_y = y*region_height
	end
	
	--// Get/set the opacity of the component
		--value (number, non-negative integer) - opacity of the component, 0 to 255 where 0 is transparent and 255 is opaque
	function new_control:get_opacity() return opacity end
	function new_control:set_opacity(value) opacity = tonumber(value) end
	
	--// Get/set whether the image is visible (newly created images are visible by default)
		--value (boolean) - if true then the image is visible
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
	
	--// Draws the image on the specified destination surface
		--dst_surface (sol.surface) - surface on which to draw the image
		--x (number, optional) - x coordinate of where to draw the image
		--y (number, optional) - y coordinate of where to draw the image
	function new_control:draw(dst_surface, x, y)
		if is_visible then
			local x = x + position.x
			local y = y + position.y
			
			surface:set_opacity(opacity)
			
			if region_width then
				surface:draw_region(
					region_x, region_y, region_width, region_height, dst_surface, x, y
				)
			else surface:draw(dst_surface, x, y) end
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
