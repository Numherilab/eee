--[[default_destination_checker.lua
	version 1.0
	25 Jan 2021
	GNU General Public License Version 3
	author: Llamazing
	
	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/
	
	This script reads all map.dat files and lists any maps that have multiple destinations
	where none have been designated as the default destination.
	
	Usage:
	require"scripts/default_destination_checker"() --checks all maps
	require"scripts/default_destination_checker"(map_id) --checks only map_id (string)
]]

local dest_checker = setmetatable({}, {
	__call = function(self, ...)
		local n = select('#', ...)
		if n>0 then
			return self:check_map(...)
		else return self:check_all_maps() end
	end,
})

function dest_checker:check_map(map_id)
	assert(type(map_id)=="string", "Bad arguement #1 to 'check_map' (string expected)")
	
	local dest_count = 0
	local is_default_found = false
	
	local env = setmetatable({}, {__index = function() return function() end end})
	
	function env.destination(properties)
		dest_count = dest_count + 1
		if properties.default==true then is_default_found = true end
	end
	
	local chunk, err = sol.main.load_file("maps/"..map_id..".dat")
	assert(chunk, "Error - unable to load map: "..map_id)
	setfenv(chunk, env)
	chunk()
	
	if dest_count > 2 and not is_default_found then
		local error_string = string.format("%s: no default destination found", map_id)
		print(error_string)
		return false, error_string
	else return true end
end

function dest_checker:check_all_maps()
	local map_list = sol.main.get_resource_ids"map"
	print"checking for any maps without default destination..."
	for _,map_id in ipairs(map_list) do
		self:check_map(map_id)
	end
	print"fin!"
end

return dest_checker

--[[ Copyright 2018-2021 Llamazing
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
