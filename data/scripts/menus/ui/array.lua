--[[ array.lua
	version 1.0.1
	22 Mar 2020
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/
	
	This script creates an ui subcomponent used to draw multiple components distributed in
	a horizontal or vertical array. The gap between each component (in pixels) can also be
	specified.
]]

local control = {}

--// Creates a new fill control
	--properties (table) - table containing properties defining fill behavior
		--subcomponents (table, array) - array of each subcomponent (type of table or userdata) to be drawn
			--each subcomponent must have a draw() method
		--direction (string, optional) - direction to arrange subcomponents, either "vertical" or "horizontal", default: "vertical"
		--gap (number, positive) distance in pixels for the gap between subcomponents
	--width (number) - width of the entire draw region in pixels
	--height (number) - height of the entire draw region in pixels
	--returns the newly created array object (table)
function control.create(properties, width, height)
	local new_control = {}
	
	--settings defined by data file property values
	local width = tonumber(width) --(number, positive integer) max width of component in pixels
	local height = tonumber(height) --(number, positive integer) max height of component in pixels
	local gap = tonumber(properties.gap or 0) --(number, integer, optional) spacing between subcomponents of array in pixels, default: 0
	local direction = properties.direction or "vertical" --(string, optional) direction to arrange subcomponents in array: "horizontal" or "vertical", default: "vertical"
	
	--additional settings
	local subcomponents --(table, array) list of each subcomponent in the array
	local position = {x=0,y=0} --(table, key/value) movements change the coordinates of this table, which are added as an offset to the component position when drawn
		--x (number, integer) - amount of the horizontal offset in pixels
		--y (number, integer) - amount of the vertical offset in pixels
		--movement (sol.movement or nil) - active movement of the component, if nil then the movement is done
	local is_visible = true --(boolean) component is not drawn if false, default: true
	
	--// validate data file property values
	
	assert(type(properties)=="table", "Bad argument #1 to 'create' (table expected)")
	
	--validate width
	assert(width, "Bad argument #2 to 'create' (number expected)")
	width = math.floor(width)
	assert(width>0, "Bad argument #2 to 'create' (number must be positive)")
	
	--validate height
	assert(height, "Bad argument #2 to 'create' (number expected)")
	height = math.floor(height)
	assert(height>0, "Bad argument #2 to 'create' (number must be positive)")
	
	--validate gap
	assert(gap, "Bad property gap to 'create' (number or nil expected)")
	gap = math.floor(gap)
	
	--validate direction
	assert(type(direction)=="string", "Bad property direction to 'create' (string or nil expected)")
	
	
	--// implementation
	
	--// Assigns the list of subcomponents to be elements in the array, removing any existing elements first
		--list (table, array) - list of subcomponents to be used in the array, specified as data file properties (see objectives.dat)
	function new_control:set_subcomponents(list)
		assert(type(list)=="table", "Bad argument #2 to 'set_subcomponents' (table expected)")
		
		local ui = require"scripts/menus/ui/ui" --do not require at start of script because will cause endless loading loop
		subcomponents = {} --clear previous subcomponents
		
		if #list>0 then --table is list of components to add
			for i,subcomponent in ipairs(list) do
				assert(type(subcomponent)=="table" or type(subcomponent)=="userdata",
					"Bad argument #2 to 'set_subcomponents' (table or userdata expected)"
				)
				assert(subcomponent.draw, "Bad argument #2 to 'set_subcomponents' (no draw function found for item at index "..i..")")
	
				table.insert(subcomponents, subcomponent)
			end
			assert(#subcomponents>0, "Bad argument #2 to 'set_subcomponents' (must include at least one subcomponent)")
		else --table specifies ui layer to use (string) as a template for all subcomponents along with a count (number) of the number to have in the array
			assert(type(list.layer)=="string", "Bad argument #2 to 'set_subcomponents' (table must contain layer key with string value)")
			
			local count = tonumber(list.count)
			assert(count, "Bad argument #2 to 'set_subcomponents' (table must contain count key with number value)")
			
			for i=1,count do
				local component = ui.create_preset(list.layer, list.width, list.height)
				table.insert(subcomponents, component)
			end
			assert(#subcomponents>0, "Bad argument #2 to 'set_subcomponents' (key count must have value >= 1)")
		end
		
		--handle additional subcomponent properties by calling associated setter function
		if list.text_key and self.set_text_key then --do text_key property first so text property won't be used if text_key exists
			self:set_text_key(list.text_key)
		elseif list.text and self.set_text then
			self:set_text(list.text)
		end
	end
	
	--// Returns the width and height (number) of the fill region in pixels
		--a value of nil indicates to use the entire width/height, respectively
	function new_control:get_size() return width, height end
	
	--// Get/set the distance between subcomponents in pixels
		--gap (number) distance of spacing in pixels
	function new_control:get_gap() return gap end
	function new_control:set_gap(value)
		local value = tonumber(value)
		assert(value, "Bad argument #2 tp 'set_gap' (number expected)")
		
		gap = math.floor(value)
	end
	
	--// Gets the number of subcomponents in the array
		--returns (number, non-negative integer) - number of subcomponents
	function new_control:get_count() return #subcomponents end
	
	--// Custom iterator to get the subcomponents of the array (does not expose internal table)
		--usage: for i,subcomponent in new_control:ipairs() do
	function new_control:ipairs()
		local iter,_,start_val = ipairs(subcomponents)
		return function(_,i) return iter(subcomponents, i) end, {}, start_val
	end
	
	--// Gets the ith subcomponent of the array
		--i (number, positive integer) - index of the subcomponent to be returned
		--returns (table or nil) - ui subcomponent at the specified index or nil if it does not exist
	function new_control:get_subcomponent(i) return subcomponents[i] end
	
	--// Splits a text string at line breaks and passes each one to subcomponent set_text function
		--text (string) - string to pass to subcomponent set_text functions
	function new_control:set_text(text)
		assert(type(text)=="string", "Bad argument #2 to 'set_text' (string expected)")
		local text = text:gsub("\r\n", "\n"):gsub("\r","\n").."\n" --consolidate line breaks
		
		local lines = {}
		for line in text:gmatch"([^\n]*)\n" do
			table.insert(lines, line)
		end
		
		self:set_all("set_text", "") --clear existing text first
		self:set_all("set_text", lines)
	end
	
	--// Same as new_control:set_text but specifies a strings.dat key so that the text will be localized in the current language
	--// The localized text string is split at line breaks and each line assigned to individual subcomponents
		--key (string) - strings.dat key corresponding to the text that should be set
	function new_control:set_text_key(key)
		local lang_code = sol.language.get_language()
		assert(lang_code, "Language has not been set")
		
		local text = sol.language.get_string(key)
		text = text:gsub("\\n", "\n") --silly workaround for Solarus issue #468
		assert(text, "strings.dat key '"..key.."' not found for language: "..lang_code)
		
		self:set_text(text)
	end
	
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
	
	--// Get/set whether the component should be drawn
		--value (boolean) - component will be drawn if true
	function new_control:get_visible() return is_visible end
	function new_control:set_visible(value)
		assert(type(value)=="boolean", "Bad argument #2 to 'set_visible' (boolean expected)")
		is_visible = value
	end
	
	--// Get/set the x & y offset that is added to the position of where the component is drawn
		--x (number) x coordinate of the offset
		--y (number) y coordinate of the offset
	function new_control:get_xy() return position.x, position.y end
	function new_control:set_xy(x, y)
		local x = tonumber(x)
		assert(x, "Bad argument #2 to 'set_xy' (number expected)")
		
		local y = tonumber(y)
		assert(y, "Bad argument #3 to 'set_xy' (number expected)")
		
		position.x = x
		position.y = y
	end
	
	--// Get the current movement of the component
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
			local x = x + position.x
			local y = y + position.y
			
			local i_x, i_y = 0, 0 --offset for each element in array
			for _,subcomponent in ipairs(subcomponents) do
				subcomponent:draw(dst_surface, x + i_x, y + i_y)
				local i_width,i_height = subcomponent:get_size()
				
				if direction=="vertical" then
					i_y = i_y + i_height + gap
				elseif direction=="horizontal" then
					i_x = i_x + i_width + gap
				end
			end
		end
	end
	
	return new_control
end

return control

--[[ Copyright 2016-2020 Llamazing
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
