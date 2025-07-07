--[[ line2path.lua
	version 1.0.1
	25 Jan 2020
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This script converts a line path in a png image to a path movement path. The line path
	must contain exactly one pixel matching the start color. Then an unbroken, single line
	of pixels matching the path color leads to a pixel matching the stop color.
	
	The path is converted to a table containing a sequence of integers that corresponds to
	the direction of the movement for each pixel along the path. 0 is east, 1 NE, 2 north,
	3 NW, 4 west, 5 SW, 6 south, 7 SE.
	
	Usage:
	local line2path = require"scripts/line2path"
	local path_data = line2path(img_file_path)
]]

--// Searches the given image file for a pixel matching the START_COLOR, then a continuous
--// line matching the PATH_COLOR, ending with the STOP_COLOR and returns the path data.
	--file_path (string) - path to the image file to use
	--returns (table, combo) indices as sequence of directions to go from the start to end
		--x & y keys (number, non-negative integer) coordinates of start pixel
		--x_end & y_end keys (number, non-negative integer) coordinates of end pixel
	--returns nil if the specified image file cannot be found
	--NOTE: There must be exactly one pixel of the start color, and the line's path cannot
	--cross itself.
return function(file_path)
	assert(type(file_path)=="string", "Bad argument #1 to 'line2path' (string expected)")
	
	--constants
	local IMG_PATH = "path_img"
	local START_COLOR = {0, 255, 0, 255} --pixel color at the beginning of the path
	local STOP_COLOR = {255, 0, 0, 255} --pixels' color along the path
	local PATH_COLOR = {0, 0, 255, 255} --pixel color at the end of the path
	local BYTES = { --convert solarus colors to sequences of 4 RGBA bytes and use as keys
		[string.char(unpack(START_COLOR))] = "start",
		[string.char(unpack(STOP_COLOR))] = "stop",
		[string.char(unpack(PATH_COLOR))] = "path",
	}
	
	local surface = sol.surface.create(file_path) --source image
	if not surface then return nil end --image not found
	
	local width, height = surface:get_size()
	local pixels = surface:get_pixels()
	local length = pixels:len() --4 bytes for each pixel
	
	
	--## Convert pixels string bytes to table
	
	local data = {} --index = (row - 1)*(col - 1)
	local index = 0 --index 0 corresponds top left pixel
	local start_count = 0 --keep track of number of pixels found matching start color (expect exactly one)
	local start_index --index value corresponding to the start pixel
	
	--iterate thru each pixel of image and save info to data table
	for i=1,length,4 do
		local pixel_bytes = pixels:sub(i,i+3) --grabs next 4 bytes
		local marker = BYTES[pixel_bytes]
		if marker then --ignore all colors except the ones interested in
			data[index] = marker
			if marker=="start" then
				start_index = index
				start_count = start_count + 1
			end
		else
			--Uncomment this code to print all non-conforming pixel colors (may help troubleshooting)
			--[[
			if pixel_bytes:sub(4,4):byte()~=0 then
				print(
					"ignored color:",
					"x:", (index % width) + 1,
					"y:", math.floor(index / width) + 1,
					"RGBA":,
					pixel_bytes:sub(1,1):byte(),
					pixel_bytes:sub(2,2):byte(),
					pixel_bytes:sub(3,3):byte(),
					pixel_bytes:sub(4,4):byte()
				)
			end
			]]
		end
		index = index + 1
	end
	
	assert(start_count<2, string.format("Error in line2path: more than one start marker (img: %s)", file_path))
	assert(start_count>0, string.format("Error in line2path: no start marker found (img: %s)", file_path))
	
	
	--## Trace line path
	
	local seen_list = {} --list of indicies already checked
	local path = {
		x = (start_index % width) + 1, --add 1 to convert from 0-based to 1-based
		y = math.floor(start_index / width) + 1,
	}
	
	--// seeks and returns index of next pixel along path given current index (recursive)
		--index (number, non-negative integer) - the current pixel along the path
		--return #1 (number, non-negative integer or false) - the next index along the path
			--false when the end of the path has been found
		--return #2 (number, non-negative integer) - direction to the next pixel
			--0 east, 1 NE, 2 north, 3 NW, 4 west, 5 SW, 6 south, 7 SE
			--no return if the first return is false
	local function find_next(index)
		if data[index] == "stop" then --stop pixel found, end of path
			path.x_end = (index % width) + 1 --add 1 to convert from 0-based to 1-based
			path.y_end = math.floor(index / width) + 1
			return false --exit loop
		end
		
		seen_list[index] = true --mark current pixel as checked
		
		local col = index % width
		local is_left = col==0 --true if pixel is along left edge of image
		local is_right = col==width-1 --true if pixel is on right edge
		local is_top = index<width --true if pixel is along top edge
		local is_bottom = index>=width*(height-1) --true if pixel is along bottom edge
		local adjacent_index --check each adjacent pixel, save each index temporarily
		local next_index --keep track of the index of the next pixel along path
		local next_dir --0 east, 1 NE, 2 north, 3 NW, 4 west, 5 SW, 6 south, 7 SE
		local next_count = 0 --keep track of number of new path pixels connected to current (expect exactly one)
		
		
		--## Check non-diagonals first
		
		--check pixel above
		if not is_top then --pixel above doesn't exist if on top row
			adjacent_index = index - width
			if not seen_list[adjacent_index] and data[adjacent_index] then --pixel above is either path or stop color
				next_index = adjacent_index
				next_dir = 2
				next_count = next_count + 1
			end
		end
		
		--check pixel to right
		if not is_right then --pixel to right doesn't exist in right-most column
			adjacent_index = index + 1
			if not seen_list[adjacent_index] and data[adjacent_index] then --pixel to right is either path or stop color
				next_index = adjacent_index
				next_dir = 0
				next_count = next_count + 1
			end
		end
		
		--check pixel below
		if not is_bottom then --pixel below doesn't exist if on bottom row
			adjacent_index = index + width
			if not seen_list[adjacent_index] and data[adjacent_index] then --pixel below is either path or stop color
				next_index = adjacent_index
				next_dir = 6
				next_count = next_count + 1
			end
		end
		
		--check pixel to left
		if not is_right then --pixel to left doesn't exist in left-most column
			adjacent_index = index - 1
			if not seen_list[adjacent_index] and data[adjacent_index] then --pixel to left is either path or stop color
				next_index = adjacent_index
				next_dir = 4
				next_count = next_count + 1
			end
		end
		
		assert(next_count<2, string.format("Error in line2path: branching path found (img: %s)", file_path))
		if next_count==1 then return next_index, next_dir end --next pixel along path found
		
		
		--## Next pixel not found, now check diagonal pixels
		
		--check upper-left pixel
		if not is_top or not is_left then --pixel to upper-left doesn't exist if in top-left corner
			adjacent_index = index - width - 1
			if not seen_list[adjacent_index] and data[adjacent_index] then --pixel to upper-left is either path or stop color
				next_index = adjacent_index
				next_dir = 3
				next_count = next_count + 1
			end
		end
		
		--check upper-right pixel
		if not is_top or not is_right then --pixel to upper-right doesn't exist if in top-right corner
			adjacent_index = index - width + 1
			if not seen_list[adjacent_index] and data[adjacent_index] then --pixel to upper-right is either path or stop color
				next_index = adjacent_index
				next_dir = 1
				next_count = next_count + 1
			end
		end
		
		--check lower-right pixel
		if not is_bottom or not is_right then --pixel to lower-right doesn't exist if in bottom-right corner
			adjacent_index = index + width + 1
			if not seen_list[adjacent_index] and data[adjacent_index] then --pixel to lower-right is either path or stop color
				next_index = adjacent_index
				next_dir = 7
				next_count = next_count + 1
			end
		end
		
		--check lower-left pixel
		if not is_bottom or not is_right then --pixel to lower-left doesn't exist if in bottom-left corner
			adjacent_index = index + width - 1
			if not seen_list[adjacent_index] and data[adjacent_index] then --pixel to lower-left is either path or stop color
				next_index = adjacent_index
				next_dir = 5
				next_count = next_count + 1
			end
		end
		
		assert(next_count<2, string.format("Error in line2path: branching path found (img: %s)", file_path))
		assert(next_count>0, string.format("Error in line2path: path does not end with stop marker (img: %s)", file_path))
		
		return next_index, next_dir
	end
	
	index = start_index --starting pixel
	local direction
	while index do
		index, direction = find_next(index)
		path[#path+1] = direction --direction may be nil (at end pixel)
	end
	
	return path
end

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
