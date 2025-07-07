--[[ pause_menu.lua
	version 1.0.1
	29 Dec 2019
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This menu script uses left/right sliding transitions to switch the active submenu from
	among a defined list. It also recalls the last submenu viewed when opened and includes
	a sliding transition from/to the top of the screen when the menu is opened/closed.
--]]

local multi_events = require"scripts/multi_events"

--sub-menus
local quest_log = require"scripts/menus/quest_log"
local inventory = require"scripts/menus/inventory"
local map_screen = require"scripts/menus/map"
local status_screen = require"scripts/menus/status"

local pause_menu = {
	x=0, y=0,
	--provide access to submenus
	inventory = inventory,
	quest_log = quest_log,
	map_screen = map_screen,
	status_screen = status_screen,
}
multi_events:enable(pause_menu)

local active_movements = {}
local active_submenu --the submenu that is currently being viewed, possible values are string from SUBMENU_LIST ids
local is_changing_menus = false --true while switching between submenus to block switching menus again until animation is done
local is_exiting = false --true or false - determines whether the pause command opens or closes the menu

--constants
local MOVEMENT_SPEED = 700 --menu movement speed in pixels per second

local SUBMENU_LIST = { --order matters
	inventory,
	quest_log,
	map_screen,
	status_screen,
}
for i,menu in ipairs(SUBMENU_LIST) do pause_menu[i] = menu end

--pause_menu.quick_keys = {}
for i,submenu in ipairs(SUBMENU_LIST) do
	SUBMENU_LIST[submenu]=i --add reverse lookup
	submenu.pause_menu = pause_menu --allow submenu to access pause menu
	--if i <=8 then pause_menu.quick_keys["f"..(i+1)] = i end --allow f2 and up to f8 to toggle opening/closing a specific submenu
end

local ANGLES = { --converts direction 0-3 to angle in radians
	[0] = 0,
	[1] = math.pi/2,
	[2] = math.pi,
	[3] = math.pi*3/2,
}

--Create a transparent background behind the menus to lower distaction from game map
local transparent_background = sol.surface.create()
transparent_background:set_opacity(100)
transparent_background:fill_color{0,0,0}


--// Begins a sliding transition for the specified submenu
	--submenu_index (number, positive integer) index of submenu to slide
	--direction (number, non-negative integer) the direction to move the submenu: 0 = right, 1 = up, 2 = left, 3 = down
	--is_start_offscreen (boolean, optional) true slides submenu onscreen, false slides submenu offscreen, default: false
		--if sliding submenu offscreen, then submenu starts from its current position
	--callback (function, optional) function to call once movement is complete
	--NOTE: to transition from active submenu to another, 2 slide transitions need to be performed simultaneously (close active & open new submenu)
local function do_slide_transition(submenu_index, direction, is_start_offscreen, callback)
	local screen_width,screen_height = sol.video.get_quest_size()
	
	local submenu = SUBMENU_LIST[submenu_index]
	assert(submenu, "Bad argument #1 to 'do_slide_transition', invalid index: "..tostring(submenu_index))
	
	if is_start_offscreen and is_start_offscreen~=true then --treat 3rd argument as callback function, ignore 4th argument
		callback = is_offscreen
		is_start_offscreen = false
	end
	
	local max_dist = (direction % 2)==0 and screen_width or screen_height --distance of the movement
	
	if is_start_offscreen then --move submenu offscreen before start of movement if is_start_offscreen is set
		local x_mult = 0
		if direction==0 then --for movement right, first move off-screen to left
			x_mult = -1
		elseif direction==2 then --for movement left, first move off-screen to right
			x_mult = 1
		end
		
		local y_mult = 0
		if direction==1 then --for movement up, first move off-screen to bottom
			y_mult = 1
		elseif direction==3 then --for movement down, first move off-screen to top
			y_mult = -1
		end
		
		submenu:set_xy(x_mult*screen_width, y_mult*screen_height) --set initial position of submenu
	else --otherwise use current position of submenu to determine distance remaining to close it
		local x,y = submenu:get_xy()
		local mult = (direction % 3) > 0 and 1 or -1 --positive if moving up or left, negative if moving right or down
		local offset = direction % 2 == 0 and x or y --use x position if moving left or right, y position if moving up or down
		
		max_dist = max_dist + mult*offset --recalculate distance based on current position
	end
	
	--create and setup movement
	local movement = sol.movement.create"straight"
	movement:set_angle(ANGLES[direction] or 0)
	movement:set_max_distance(max_dist)
	movement:set_speed(MOVEMENT_SPEED)
	
	--save record of movement in case it is interrupted
	active_movements[movement] = {
		submenu_index = submenu_index,
		direction = direction,
		is_closing = not is_start_offscreen,
	}
	
	--start movement
	movement:start(submenu, function()
		if not is_start_offscreen then
			sol.menu.stop(submenu)
			submenu:set_xy(0,0) --reset its position to center of screen
		end
		
		if callback then callback() end
		active_movements[movement] = nil --delete record now that movement is done
	end)
	
	return movement
end

--// Aborts all active movements and replaces them with new movements to slide those submenus to the top of the screen and close them
--// the active submenu is not assigned a new movement, which should be done by the user after calling this function
	--callback (function, optional) callback function to call once movement is complete
local function close_other_submenus(callback)
	local submenu_count = 1 --start at 1 to include active submenu in count
	
	--calls this function when each submenu is finished
	local function on_finished()
		submenu_count = submenu_count - 1
		if submenu_count == 0 then --all movements done
			if callback then callback() end
		end
	end
	
	--stop all existing movements and save info describing each movement
	local stopped_movements = {}
	for movement,data in pairs(active_movements) do
		movement:stop()
		active_movements[movement] = nil
		stopped_movements[#stopped_movements+1] = data
	end
	
	--create new movements to replace the stopped movements, now moving the submenu to the top of the screen to close it; skips the active submenu
	for _,data in ipairs(stopped_movements) do
		local submenu = SUBMENU_LIST[data.submenu_index]
		if submenu ~= active_submenu then
			submenu_count = submenu_count + 1
			do_slide_transition(data.submenu_index, 1, false, on_finished)
		end
	end
	stopped_movements = nil --no longer needed
	
	return on_finished --user should call do_slide_transition() on the active submenu and use on_finished as the callback
end

--// Closes all submenus and opens the active submenu using a transition from the top of the screen
	--callback (function, optional) callback function to call once movement is complete
local function reopen_active_submenu(callback)
	local game = sol.main.get_game()
	
	if not active_submenu then pause_menu:recall_saved_submenu() return end
	if not sol.menu.is_started(active_submenu) then sol.menu.start(game, active_submenu) end
	
	sol.menu.bring_to_front(active_submenu) --ensure in front of old submenu
	sol.menu.bring_to_front(pause_menu) --bring pause menu to front temporarily so it can block inputs during transition
	is_changing_menus = true
	is_exiting = false
	
	--callback function for when all movements are done
	local function on_finished()
		is_changing_menus = false --stop blocking inputs
		sol.menu.bring_to_front(active_submenu)
			
		if callback then callback() end
	end
	
	local new_callback = close_other_submenus(on_finished)
	
	--create closing movement for active submenu to top of screen
	do_slide_transition(SUBMENU_LIST[active_submenu], 3, true, new_callback)
end

--// Reopens the most recent submenu from last time menu was viewed
function pause_menu:recall_saved_submenu()	
	local game = sol.main.get_game()
	
	--start pause menu if not already started
	if not sol.menu.is_started(self) then
		active_submenu = nil --make sure the active menu is not set
		sol.menu.start(game, self)
		return --starting the pause menu will call self:recall_saved_submenu() again after initialization
	end
	
	local last_index = game:get_value"last_submenu" or 1
	active_submenu = SUBMENU_LIST[last_index]
	
	reopen_active_submenu()
end

--// Save currently viewed submenu so that it will be the one opened next time
function pause_menu:save_submenu()
	local game = sol.main.get_game()
	local active_index = SUBMENU_LIST[active_submenu] --may be nil
	game:set_value("last_submenu", active_index)
end

--// Activates the specified submenu if not open, otherwise closes it
	--index (number, positive integer) index of submenu to toggle
function pause_menu:toggle_submenu(index)
	index = tonumber(index)
	assert(index, "Bad argument #2 to 'toggle_submenu' (number expected)")
	local submenu = SUBMENU_LIST[index]
	assert(submenu, "Bad argument #2 to 'toggle_submenu', invalid index: "..index)
	
	local game = sol.main.get_game()
	
	local old_submenu = active_submenu
	active_submenu = submenu --make the submenu to be toggled the active one
	local active_index = SUBMENU_LIST[active_submenu]
	
	--if pause menu is not active then need to start it
	if not sol.menu.is_started(self) then
		sol.menu.start(game, self)
		return --starting the pause menu will start the active submenu as well, we're done here
	end
	
	--determine whether active submenu is opening or closing
	local is_closing = not sol.menu.is_started(active_submenu)
	for _,data in pairs(active_movements) do
		if data.submenu_index==active_index then
			is_closing = data.is_closing
			break
		end
	end
	
	if is_closing then
		sol.menu.bring_to_front(self) --bring pause menu to front temporarily so it can block inputs during transition
		is_changing_menus = true --start blocking keyboard/controller inputs
		is_exiting = false
		
		if old_submenu then do_slide_transition(SUBMENU_LIST[old_submenu], 1, false) end
		reopen_active_submenu()
	else self:close() end
end

local DIRECTIONS = { --convert left/right to direction
	left = -1, --previous SUBMENU_LIST entry
	right = 1, --next SUBMENU_LIST entry
}
--// Switch active submenu using a scroll transition
	--direction (string, optional) - possible values: "right" or "left", moves to the submenu on the right or left respectively
		--default: "right"
function pause_menu:next_submenu(direction)
	assert(sol.menu.is_started(self), "Error: pause menu must be started before switching submenus")
	if is_changing_menus then return end --do nothing if already in transition
	
	direction = direction or "right" --scroll right by default
	assert(direction, "Bad argument #2 to 'next_submenu' (string or nil expected)")
	local dir_num = DIRECTIONS[direction] --convert left/right to -1/1
	assert(direction, "Bad argument #2 to 'next_submenu', invalid direction: "..direction)
	
	local game = sol.main.get_game()
	
	--determine current and next submenus
	local old_submenu = active_submenu
	local old_index = SUBMENU_LIST[active_submenu]
	local new_index = old_index + dir_num
	if new_index < 1 then
		new_index = #SUBMENU_LIST
	elseif new_index > #SUBMENU_LIST then
		new_index = 1
	end
	local new_submenu = SUBMENU_LIST[new_index]
	if new_submenu~=old_submenu then
		active_submenu = new_submenu
	else return end --do nothing if new submenu is current submenu
	
	--open new submenu and move on screen
	sol.menu.start(game, new_submenu)
	sol.audio.play_sound("cursor_low")
	do_slide_transition(SUBMENU_LIST[new_submenu], dir_num + 1, true, function()
		is_changing_menus = false --stop blocking inputs
		sol.menu.bring_to_front(new_submenu) --now submenu processes inputs first
	end)

	sol.menu.bring_to_front(self) --bring pause menu to front temporarily so it can block inputs during transition
	is_changing_menus = true --start blocking keyboard/controller inputs
	
	--move old submenu off screen and close
	do_slide_transition(SUBMENU_LIST[old_submenu], dir_num + 1, false)
end

--// Slides the active submenu to the top of the screen then closes it (and closes the pause menu too)
	--callback (function, optional) callback function to call once movement is complete
function pause_menu:close(callback)
	assert(sol.menu.is_started(self), "Error: pause menu must be started before it can be closed")
	
	sol.menu.bring_to_front(self) --bring pause menu to front temporarily so it can block inputs during transition
	is_changing_menus = true
	is_exiting = true
	
	--callback function for when all movements are done
	local function on_finished()
		sol.menu.stop(self)
		if callback then callback() end
	end
	
	local new_callback = close_other_submenus(on_finished) --close any submenus that have an active movement (except the active submenu)
	
	--create closing movement for active submenu to top of screen
	do_slide_transition(SUBMENU_LIST[active_submenu], 1, false, new_callback)
end

--// Gets/sets the x,y position of the menu in pixels
function pause_menu:get_xy() return self.x, self.y end
function pause_menu:set_xy(x, y)
	x = tonumber(x)
	assert(x, "Bad argument #2 to 'set_xy' (number expected)")
	y = tonumber(y)
	assert(y, "Bad argument #3 to 'set_xy' (number expected)")
	
	self.x = math.floor(x)
	self.y = math.floor(y)
end

function pause_menu:on_started()
	local game = sol.main.get_game()
	assert(game, "Error: cannot start pause menu because no game is currently running")
	game:set_paused(true)
	is_exiting = false
	
	--STUFF FROM MAX:
	--a couple submenus need to be initialized before they can be started.
	for _,submenu in ipairs(SUBMENU_LIST) do
		if submenu.initialize then submenu:initialize(game) end
	end
	
	--clean-up any residual active movements
	for movement,data in pairs(active_movements) do
		movement:stop()
		active_movements[movement] = nil
		
		--recenter submenu
		local submenu = SUBMENU_LIST[data.submenu_index]
		submenu:set_xy(0, 0)
	end
	
	if active_submenu then --if active_submenu has been set then this is the submenu to open
		if not sol.menu.is_started(active_submenu) then sol.menu.start(game, active_submenu) end
		
		--block keyboard/controller inputs during transition
		sol.menu.bring_to_front(pause_menu)
		is_changing_menus = true
		
		do_slide_transition(SUBMENU_LIST[active_submenu], 3, true, function()
			is_changing_menus = false --stop blocking inputs
			sol.menu.bring_to_front(active_submenu) --active submenu processes inputs first
		end)
	else self:recall_saved_submenu() end --otherwise recall most recent submenu
end

function pause_menu:on_finished()
	local game = sol.main.get_game()
	
	self:save_submenu()
	
	--tell submenus that pause menu is closing
	for _,submenu in ipairs(SUBMENU_LIST) do
		if submenu.on_pause_menu_finished then submenu:on_pause_menu_finished() end
	end
	
	active_submenu = nil
	is_changing_menus = false
	is_exiting = false
	
	game:set_paused(false)
end

function pause_menu:on_command_pressed(command)
  --if is_changing_menus then return true end
	if command=="pause" then
		if not is_exiting then
			self:close()
		else reopen_active_submenu() end
		
		return true
	elseif command=="left" or command=="right" then
		if not is_changing_menus and not is_exiting then --must wait for transition to finish before changing submenus again
			self:next_submenu(command)
			
			return true
		elseif is_exiting then return true end --block command from going to submenu
	--elseif command=="up" or command=="down" then
	--	if is_exiting then return true end --block command from going to submenu
	elseif command == "attack" then
		if not is_exiting then
			self:close()
			return true
		end
	end
	
	if is_changing_menus or is_exiting then return true end --block all commands during transition
end

function pause_menu:on_draw(dst)
  transparent_background:draw(dst)
end


--Avoid analog stick from registering more than one directional event when held down:
local joy_avoid_repeat = {-2, -2}
function pause_menu:on_joypad_axis_moved(axis, state)
  local handled = joy_avoid_repeat[axis] == state
  joy_avoid_repeat[axis] = state      

  return handled
end


return pause_menu

--[[ Copyright 2019 Llamazing
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
