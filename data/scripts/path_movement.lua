--[[ path_movement.lua
	version 1.0
	28 Dec 2019
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This script creates a path movement for a sprite. Unlike sol.movement of type path, it
	allows for movements in single pixel increments, and pauses can be added by specifying
	values of 10 or greater in the path (delay in milliseconds). No collision detection is
	enabled.
]]

local DIAGONAL_DIST = math.sqrt(2) --account for longer distance traveling diagonally
local DIRECTIONS = { --convert direction to x & y pixel offset
	[0] = {x=1, y=0},
	[1] = {x=1, y=-1},
	[2] = {x=0, y=-1},
	[3] = {x=-1, y=-1},
	[4] = {x=-1, y=0},
	[5] = {x=-1, y=1},
	[6] = {x=0, y=1},
	[7] = {x=1, y=1},
}

local path_movement = {}

--// Creates new movement object (movement is started immediately if object is specified)
	--properties (table, key/value) properties of movement, possible keys:
		--path (table, array) --direction of each step of movement (0-7), values > 10 are delay in msec
		--speed (number, positive, optional) speed of movement in pixels per second
		--loop (boolean, optional) true causes the movement to repeat indefinitely, default true --not yet implemented
	-- if object is specified then start immediately, otherwise the following are ignored
		--object (table or userdata, optional) the object to move
		--context (table or userdata, optional) context to use for the movement
		--x, y (number, integer, optional) starting coordinates of object in pixels
			--the object position will be set to these coordinates then the movement is started
		--callback (function, optional) callback function to call at end of movement
function path_movement.create(properties)
	local movement = {} --(table, key/value) the newly created movement object
	local path = {} --(table, array) each step of the movement
		--direction 0-7 or values >= 10 delay for that many msec delay
	
	local object --(table or sol.drawable) object to move
	local inv_speed --(number, positive) msec / pixel, min value of 10 (max speed of 100 pixels/sec)
	local remainder --(number, non-negative) up to 10 msec of error in delay times
	local direction --(number, non-negative integer) 0 (east) to 7 (SE), the current direction of the movement or nil if not active
	local timer --(sol.timer) repeating timer that is active during movement
	local movement_callback --(function, optional) callback function to call at end of movement
	
	local index = 0 --current path index of the movement, 0 means movement hasn't started
	local loop = false --TODO implement loop feature
	local is_sprite --true if object is a sol.sprite (sets the direction automatically)
	
	--make copy of path table given in properties
	assert(type(properties.path)=="table" or not path, "Bad property 'path' to 'create' (table or nil expected)")
	for i,v in ipairs(properties.path or {}) do --copy to new table
		local num_val = tonumber(v)
		assert(num_val, "Bad property 'path' to 'create', table array values must be numbers")
		num_val = math.floor(num_val)
		assert(num_val>=0, "Bad property 'path' to 'create', table array number values must be positive")
		
		path[i] = num_val
	end
	
	do --convert pixels per second speed to msec per pixel
		local speed = tonumber(properties.speed or 32)
		assert(speed, "Bad property 'speed' to 'create' (number or nil expected)")
		inv_speed = 1000/speed
		if inv_speed < 10 then inv_speed = 10 end --TODO remove speed cap
	end
	
	--// Moves object by delta x & y distances in pixels and triggers on_position_changed events
		--dx (number, integer) amount to move object in x direction in pixels
		--dy (number, integer) amount to move object in y direction in pixels
	local function move_object(dx, dy)
		if object.set_xy then
			local x, y = object:get_xy()
			object:set_xy(x+dx, y+dy)
		else
			local x = object.x or 0
			local y = object.y or 0
			
			object.x = x + dx
			object.y = x + dy
		end
		
		if movement.on_position_changed then movement:on_position_changed() end
		if object.on_position_changed then object:on_position_changed() end
	end
	
	--// Updates the direction of the movement and triggers the direction_changed event
		--new_direction (number, non-negative integer) direction from 0 to 7
	local function set_direction(new_direction)
		if new_direction==direction then return end --do nothing if direction didn't change
		direction = new_direction
		
		if is_sprite then
			if direction <= object:get_num_directions() then
				object:set_direction(direction)
			end
		end
		
		if movement.on_direction_changed then movement:on_direction_changed(direction) end
	end
	
	--// Call when movement is finished to trigger on_movement_finished event and do clean-up
	local function movement_finished()
		if movement.on_finished then movement:on_finished() end
		if object.on_movement_finished then object:on_movement_finished() end
		
		if movement_callback then movement_callback() end
		
		index = 0
		remainder = 0
		object = nil
		is_sprite = nil
		timer = nil
	end
	
	--// Repeatedly called after each step of movement by timer
		--returns delay time in msec for next iteration of timer (or no return if movement is complete)
	local function timer_check()
		local next_delay --(number, positive integer) delay value to be returned in msec (will be increment of 10)
		
		
		--## Perform movement from previous step
		
		--move object by previous increment now that timer has finished
		local path_value = path[index]
		local trajectory = DIRECTIONS[path_value]
		if trajectory then move_object(trajectory.x, trajectory.y) end
		
		index = index + 1
		path_value = path[index]
		
		--TODO check if need to immediately perform another step, only applicable if speed > 100 pixels/sec
		--while remainder >= inv_speed do
		--end
		
		
		--## Calculate delay until next step of movement
		
		if path_value then
			if path_value < 10 then
				local dist = path_value % 2 == 0 and 1 or DIAGONAL_DIST --diagonal step is slightly farther distance
				local delay = dist*inv_speed - remainder
				next_delay = math.ceil(delay/10)*10 --round up to 10 msec increments
				remainder = next_delay - delay
				
				local next_value = path[index+1]
				if direction ~= next_value or not next_value then --don't change direction if going to change back next step, reduces jitter
					set_direction(path_value) --update sprite direction to match next movement step
				end
			else next_delay = path_value end --the path value is the delay (wait with no movement)
		else movement_finished() end --no more path entries (returns nil)
		
		return next_delay
	end
	
	--// Initiates repeating timer at start of movement
		--context (table or userdata) context to use for the timer
	local function start_movement(context)
		if timer then timer:stop() end --abort existing movement if active
		index = 0 --reset index to beginning
		remainder = 0
		
		local delay = timer_check() --delay for first step
		timer = sol.timer.start(context or sol.main, delay, timer_check)
		
		--initialize object position only if not already set
		if not object.set_xy then --do nothing if postion set via function
			if not object.x then object.x = 0 end
			if not object.y then object.y = 0 end
		end 
		
		--NOTE: don't call object:on_movement_started(movement) because this is not a real movement and therefore cannot pass a movement parameter
	end
	
	--// Begins the movement
		--object_to_move (table or userdata) the object to move
		--context (table or userdata, optional) the context for the movement (causes timer to abort)
			--suspends movement when game paused if context is sol.game
		--callback (function, optional) callback function to be called at end of the movement
	function movement:start(object_to_move, context, callback)
		assert(type(object_to_to_move)=="table" or type(object_to_move)=="userdata", "Bad argument #2 to 'start' (table or userdata expected)")
		object = object_to_move
		is_sprite = sol.main.get_type(object)=="sprite"
		
		if type(context)=="function" then --context is omitted and 3rd arg is really the callback function
			callback = context
			context = nil
		end
		
		assert(type(context)=="table" or type(context)=="userdata" or not context, "Bad argument #3 to 'start' (table or userdata or nil expected)")
		assert(type(callback)=="function" or not callback, "Bad argument #4 to 'start' (function or nil expected)")
		
		movement_callback = callback
		
		start_movement(context)
	end
	
	--// Aborts the movement
	function movement:stop()
		if timer then timer:stop() end
		
		index = 0
		remainder = 0
		object = nil
		is_sprite = nil
		timer = nil
	end
	
	--// Returns the current coordinates (number) of the object being moved (no return if movement not started)
	function movement:get_xy()
		if object then
			if object.get_xy then
				return object:get_xy()
			elseif object.x and object.y then
				return object.x, object.y
			end
		end
	end
	
	--// Sets the position of the object being moved (no effect if movement is not started)
	function movement:set_xy(x, y)
		if object then
			if not object.set_xy then
				object.x = x
				object.y = y
			else object:set_xy(x, y) end
		end
	end
	
	--// Returns the object being moved (returns nil if movement is not started)
	function movement:get_object() return object end
	
	--// Returns true if movement is active, else returns false
	function movement:is_active()
		if timer then
			return timer:get_remaining_time() > 0
		else return false end
	end
	
	--// Returns true if the movement is currently suspended, false if active, no return if not started
	function movement:is_suspended()
		if timer then return timer:is_suspended() end
	end
	
	--// Suspends the movement if active (otherwise no effect)
		--boolean (boolean, optional) true suspends the movement, false resumes
	function movement:set_suspended(boolean)
		if timer then timer:set_suspended() end
	end
	
	--// Returns the current direction of the movement (number, integer) 0 to 7
		--returns nil if movement is not started
	function movement:get_direction() return direction end
	
	--// Returns the path of the movement (table, array)
	function movement:get_path()
		local path_copy = {}
		for i,v in ipairs(path) do path_copy[i] = v end
		return path_copy
	end
	
	--// Returns the current position of the movement in the path table
		--returns (number, non-negative integer) current index of movement in path table
			--if movement is not started then returns 0
	function movement:get_path_position() return index end
	
	--// Sets the path for the movement (table, array)
		--direction 0-7 or values >= 10 delay for that many msec delay
		--0 is east, 1 NE, 2 north, 3 NW, 4 west, 5 SW, 6 south, 7 SE
	function movement:set_path(new_path)
		assert(type(new_path)=="table", "Bad argument #2 to 'set_path' (table expected)")
		
		path = {}
		for i,v in ipairs(new_path) do --copy to new table
			local num_val = tonumber(v)
			assert(num_val, "Bad argument #2 to 'set_path', table array values must be numbers")
			num_val = math.floor(num_val)
			assert(num_val>=0, "Bad argument #2 to 'set_path', table array number values must be positive")
			
			path[i] = num_val
		end
		
		index = 0 --reset index to beginning
		remainder = 0
	end
	
	--// Returns the number of entries in the path table of the movement
	function movement:get_path_count() return #path end
	
	--// get/set the speed of the movement
		--(number, positive) speed in pixels per second
		--NOTE: doesn't take affect until next step of movement (when current timer expires)
	function movement:get_speed() return 1/inv_speed/1000 end
	function movement:set_speed(new_speed)
		new_speed = tonumber(new_speed)
		assert(new_speed, "Bad argument #2 to 'set_speed' (number expected)")
		assert(new_speed>0, "Bad argument #2 to 'set_speed', number must be positive")
		
		inv_speed = 1000/new_speed --units of msec per pixel
	end
	
	--// get/set functions for whether the movement repeats
		--(boolean) true means the loop repeats (continues from position at end of path)
	function movement:get_loop() return loop end
	function movement:set_loop(boolean)
		if boolean==nil then boolean = true end --default is true
		assert(type(boolean)=="boolean", "Bad argument #2 to 'set_loop' (boolean or nil expected)")
		loop = boolean
	end
	
	
	--## Start movement now if object to move was included in properties
	
	if properties.object then
		local obj_type = type(properties.object)
		assert(obj_type=="table" or obj_type=="userdata", "Bad property 'object' to 'create' (table or userdata or nil expected)")
		object = properties.object
		
		local context = properties.context or sol.main
		assert(type(context)=="table" or type(context)=="userdata", "Bad property 'context' to 'create' (table or userdata or nil expected)")
		
		local callback = properties.callback
		if callback then
			assert(type(callback)=="function", "Bad property 'callback' to 'create' (function or nil expected)")
		end
		
		--set initial position of object if x & y specified in properties
		local x = properties.x
		local y = properties.y
		if x and y then
			assert(type(x)=="number", "Bad property 'x' to 'create' (number or nil expected)")
			assert(type(y)=="number", "Bad property 'y' to 'create' (number or nil expected)")
			if not object.set_xy then
				object.x = x
				object.y = y
			else object:set_xy(x, y) end
		end
		
		movement:start(properties.object, context, callback)
	end
	
	return movement
end

return path_movement

--[[ Copyright 2019 Llamazing
	[] 
	[] This program is free software: you can redistribute it and/or modify it under the
	[] terms of the GNU General Public License as published by the Free Software Foundation,
	[] either version 3 of the License, or (at your option) any later version.
	[] 
	[] It is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	[] without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
	[] PURPOSE.	See the GNU General Public License for more details.
	[] 
	[] You should have received a copy of the GNU General Public License along with this
	[] program.	If not, see <http://www.gnu.org/licenses/>.
	]]
