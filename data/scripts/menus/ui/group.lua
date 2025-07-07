--[[ group.lua
	version 1.0
	15 Dec 2018
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/
	
	This script creates an ui subcomponent used to draw multiple components onto a surface
	using specified x & y coordinates for each. A manual refresh is needed whenever any of
	those components are updated.
]]

local control = {}

--methods to inherit from sol.surface
local SURFACE_METHODS = {
	get_opacity = true,
	set_opacity = true,
	get_blend_mode = true,
	set_blend_mode = true,
	fade_in = true,
	fade_out = true,
	get_xy = true,
	set_xy = true,
	get_movement = true,
	stop_movement = true,
}

--// Creates a new group object
	--properties (table) - table containing properties defining group behavior
		--subcomponents (table, array) - array of each subcomponent (type of table or userdata) to be drawn
			--each entry is a table containing the subcomponent, x coordinate, and y coordinate as the first 3 values
	--width (number) - width of the entire draw region in pixels
	--height (number) - height of the entire draw region in pixels
	--returns the newly created array object (table)
function control.create(properties, width, height)
	local new_control = {}
	
	--// validate data file property values
	local width = width --(number, positive integer) max width of component in pixels, if nil then fills entire destination surface
	local height = height --(number, positive integer) max height of component in pixels, if nil then fills entire destination surface
	
	--additional settings
	local surface --intermediate surface to draw subcomponents on
	local subcomponents = {} --(table, array) list of each subcomponent in the group, order determines draw order, first drawn first
	local positions = {}
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
	
	
	--// implementation
	
	surface = width and sol.surface.create(width, height) or sol.surface.create()
	
	--inherit methods of sol.surface
	setmetatable(new_control, { __index = function(self, name)
		if SURFACE_METHODS[name] then
			return function(_, ...) return surface[name](surface, ...) end
		else return function() end end
	end})
	
	--// Assigns the list of subcomponents to be elements in the group, removing any existing elements first
		--list (table, array) - list of subcomponents to be used in the group, specified as data file properties (see objectives.dat)
	function new_control:set_subcomponents(list)
		assert(type(list)=="table", "Bad argument #2 to 'set_subcomponents' (table expected)")
		
		local ui = require"scripts/menus/ui/ui" --do not require at start of script because will cause endless loading loop
		subcomponents = {} --clear previous subcomponents
		
		if #list>0 then
			for i,entry in ipairs(list) do
				assert(type(entry)=="table", "Bad argument #2 to 'set_subcomponents' (table expected)")
				
				local subcomponent = entry[1]
				assert(type(subcomponent)=="table" or type(subcomponent)=="userdata",
					"Bad argument #2, index "..i..", 1 to 'set_subcomponents' (table or userdata expected)".." got: "..type(subcomponent)
				)
				assert(subcomponent.draw, "Bad argument #2 to 'set_subcomponents' (no draw function found for item at index "..i..")")
				
				local x = math.max(math.floor(tonumber(entry[2])), 0) or 0
				local y = math.max(math.floor(tonumber(entry[3])), 0) or 0
				
				table.insert(positions, {x=x, y=y})
				table.insert(subcomponents, subcomponent)
			end
		else
			assert(type(list.layer)=="string", "Bad argument #2 to 'set_subcomponents' (table must contain layer key with string value)")
			
			local count = tonumber(list.count)
			assert(count, "Bad argument #2 to 'set_subcomponents' (table must contain count key with number value)")
			
			for i=1,count do
				local subcomponent = ui.create_preset(list.layer, list.width, list.height)
				
				local x = math.max(math.floor(tonumber(list.x)), 0) or 0
				local y = math.max(math.floor(tonumber(list.y)), 0) or 0
				
				table.insert(positions, {x=x, y=y})
				table.insert(subcomponents, subcomponent)
			end
			assert(#subcomponents>0, "Bad argument #2 to 'set_subcomponents' (key count must have value >= 1)")
		end
		assert(#subcomponents>0, "Bad argument #2 to 'set_subcomponents' (must include at least one subcomponent)")
	end
	
	--if properties table contains an array portion then use it to specify list of subcomponents
	if type(properties)=="table" and #properties>0 then
		new_control:set_subcomponents(properties)
	end
	
	--// Returns the width and height (number) of the frame in pixels
	function new_control:get_size() return width, height end
	
	--// Custom iterator to get the subcomponents of the group (does not expose internal table)
		--usage: for i,subcomponent in new_control:ipairs() do
	function new_control:ipairs()
		local iter,_,start_val = ipairs(subcomponents)
		return function(_,i) return iter(subcomponents, i) end, {}, start_val
	end
	
	--// Gets the number of subcomponents in the array
		--returns (number, non-negative integer) - number of subcomponents
	function new_control:get_count() return #subcomponents end
	
	--// Gets the ith subcomponent of the array
		--i (number, positive integer) - index of the subcomponent to be returned
		--returns (table or nil) - ui subcomponent at the specified index or nil if it does not exist
	function new_control:get_subcomponent(i) return subcomponents[i] end
	
	--// Calls the function for each subcomponent and passes it the specified value(s)
		--key (string) - name of the function to call in each subcomponent
			--any subcomponents that do not define the function will be ignored
		--values (non-nil) - value(s) to pass to each component's function
			--(table) - list of values to pass to each subcomponent's function
				--i.e. the subcomponent[i] function is passed values[i]
				--if the corresponding value in values[i] is nil then the function is not called
			--(anything else) - This same value is passed to each subcomponent's function
			--note: the function is assumed to be a method, so the subcomponent is passed
			--      as arg 1 and the value as arg 2.
	function new_control:set_all(key, values)
		assert(type(key)=="string", "Bad argument #2 to 'set_all' (string expected)")
		assert(values~=nil, "Bad argument #3 to 'set_all' (must not be nil)")
		
		if type(values)=="table" then --values contains list of values for each subcomponent
			for i,subcomponent in ipairs(subcomponents) do
				local func = subcomponent[key]
				local value = values[i]
			
				if type(func)=="function" and value~=nil then
					func(subcomponent, value)
				end
			end
		else --values is single value to be used for all subcomponents
			for _,subcomponent in ipairs(subcomponents) do
				local func = subcomponent[key]
				
				if type(func)=="function" then
					func(subcomponent, values)
				end
			end
		end	
	end
	
	--// Get/set whether the group should be drawn
		--value (boolean) - group will be drawn if true
	function new_control:get_visible() return is_visible end
	function new_control:set_visible(value)
		assert(type(value)=="boolean", "Bad arguement #1 to 'set_visible' (boolean expected)")
		is_visible = value
	end
	
	--// Assign a movement to the component and start it
		--movement (sol.movement) - movement to apply to the component
		--callback (function, optional) - function to be called once the movement has finished
	function new_control:start_movement(movement, callback) movement:start(surface, callback) end
	
	--// Draws the group on the specified destination surface
		--dst_surface (sol.surface) - surface on which to draw the group object
		--x (number, optional) - x coordinate of where to draw the group object
		--y (number, optional) - y coordinate of where to draw the group object
	function new_control:draw(dst_surface, x, y)
		if is_visible then
			surface:clear()
			for i,subcomponent in ipairs(subcomponents) do
				local position = positions[i] --convenience
				subcomponent:draw(surface, position.x, position.y) --draw subcomponents on surface
			end
			surface:draw(dst_surface, x, y) --draw surface to destination
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
