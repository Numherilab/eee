--[[ util.lua
	version 1.0
	12 Nov 2018
	GNU General Public License Version 3
	author: Llamazing
	
	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/
	
	This script contains general purpose utility functions used by the UIX library related
	to processing data files and low-level drawing tasks.
]]

local color_list = require"scripts/menus/ui/color_list.dat"

local util = {}

local loaded_images = {}
local loaded_images_lang --create table later
local loaded_lang

--// load image from file as a surface (or use existing if loaded previously)
	--path (string) - file path to the image to be loaded
	--is_language (boolean, optional) - true to load the image from the images subdirectory of the current language directory
		--default: false - loads the image from the sprites directory
	--return (sol.surface) - a surface with the loaded image
		--will return nil if the image failed to load
function util.get_image(path, is_language)	
	local images --reference to loaded_images or loaded_images_lang depending on is_language
	if is_language then
		local current_lang = sol.language.get_language()
		assert(current_lang, "Error in 'get_image', language has not been set")
		
		--if language changed then discard previously loaded language-specific images
		if current_lang ~= loaded_lang then
			loaded_images_lang = {}
			loaded_lang = current_lang
		end
		
		images = loaded_images_lang
	else images = loaded_images end
	
	local surface
	if not images[path] then --load image if not already loaded
		surface = sol.surface.create(path, is_language)
		images[path] = surface --save image so it doesn't have to be loaded again next time
	else surface = images[path] end --use previously loaded surface
	
	return surface
end

--// Verifies margin values and returns table with 4 values
	--value (number or table, optional) - converts this value to table with 4 values
		--(number) - returns table with all 4 entries equal to value
		--(table, 2 entries) - returns table with 4 entries, repeating the first 2 entries
		--(table) - returns table with 4 entries that are positive integers
			--if any of the first 4 entries are non-numeric then 0 is used instead
			--entries beyond the first 4 are ignored
		--(default) - returns table with 0 for all 4 entries
	--returns a table with 4 positive integers corresponding to right, top, left and bottom values
		--the table returned will be a copy
function util.make_margins_4(value)
	local margins = {} --4 values: right, top, left, bottom in pixels
	
	local num_value = tonumber(value)
	if num_value then --if number then use that value for all 4 entries
		--force value to positive integer, default is zero
		num_value = math.floor(num_value)
		num_value = math.max(num_value, 0)
		
		for i=1,4 do
			table.insert(margins, num_value)
		end
	elseif type(value)=="table" then
		if #value==2 then --use first value for left & right, second for top & bottom
			table.insert(value, value[1])
			table.insert(value, value[2]) 
		end
		
		for i=1,4 do
			--force value to positive integer, default value is zero
			num_value = tonumber(value[i]) or 0
			num_value = math.floor(num_value)
			num_value = math.max(num_value, 0)
		
			table.insert(margins, num_value)
		end
	else margins = {0, 0, 0, 0} end
	
	return margins
end

--// Verifies color values and returns color table
	--value (string or table) - color value to be verified
		--(string) - must be a color name from color_list.dat, returns the color table
		--(table) - contains 3 or 4 entries for red, green, blue and alpha values, range 0 to 255
	--max_count (number) - The maximum number of values in the color table
	--returns a table with 3 or 4 entries for red, green, blue and alpha values, range 0 to 255, integer values
		--the returned table will be a copy
		--if value is not valid then returns false along with a string describing the error
function util.make_RGB_color(value, max_count)
	local color = {}
	
	local max_count = tonumber(max_count)
	assert(not max_count or max_count>0, "Bad argument #2 to 'make_RGB_color' (number value must be positive)")
	
	if type(value)=="string" then
		local name = value
		value = color_list[value]
		
		if not value then return false, ", invalid color name: "..name end
	end
	
	if type(value)=="table" then
		if not max_count then
			max_count = value[4] and 4 or 3 --exclude alpha if not specified
		elseif max_count > 4 then max_count = 4 end
		
		for i=1,max_count do
			local num_value = tonumber(value[i]) or 0
			num_value = math.min(math.max(math.floor(num_value), 0), 255)
		
			table.insert(color, num_value)
		end
	else return false, " (string or table expected)" end --invalid color format
	
	return color
end

--// Replaces instances of pattern followed by 1-9 in src_text with up to 9 values from new_values table
--If the pattern exists multiple times in the source text then all instances are replaced
	--src_text (string) - text to perform substitution on
	--new_values (string or table) - string or table of strings to use as substitution values (up to 9 of them)
		--(string) - only 1 substitution is performed for the pattern appended with 1
		--(table) - The table contains up to 9 strings for each of the substitutions
			--any values of nil or false use an empty string for the substitution
	--pattern (string, optional) - pattern in src_text to be replaced (1 thru 9 gets appended to the pattern for each substitution)
		--lua pattern matching is used for the pattern, escape character % may be needed in the pattern
		--default: instances of $1 to $9 will be replaced
function util.substitute_text(src_text, new_values, pattern)
	assert(type(src_text)=="string", "Bad argument #1 to 'substitute_text' (string expected)")
	
	if type(new_values)=="string" then new_values = {new_values} end
	assert(type(new_values)=="table", "Bad argument #2 to 'substitute_text' (string or table expected)")
	assert(#new_values>0, "Bad argument #2 to 'substitute_text' (table length must not be zero)")
	
	pattern = pattern or "%$" --default: substitute for $1 to $9
	assert(type(pattern)=="string", "Bad argument #3 to 'substitute_text' (string expected)")
	
	for i=1,9 do
		assert(type(new_values[i])~=true, "Bad argument #2 to 'substitute_text' (table values cannot be value of true)")
		local sub_text = tostring(new_values[i] or "")
		src_text = src_text:gsub(pattern..i, sub_text)
	end
	
	return src_text
end

return util

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
