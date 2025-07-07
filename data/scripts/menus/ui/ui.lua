--[[ ui.lua
	version 1.0
	16 Nov 2018
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This script handles the loading of ui subcomponent scripts, which represent individual
	components that can be drawn on a menu, with behaviors defined by each script.
]]

local ui = {}

local PATH = "scripts/menus/ui/" --location of control scripts

local controls = { --control scripts to load, order matters
	"fill", --rectangular fill of solid color
	"frame", --draws an image with edges and corners and scales as necessary to any size
	"text", --draws a text surface
	"image", --draws an image loaded from a file
	"sprite", --draws a sprite animation
	"array", --draws multiple of the same control arranged horizontally or vertically
	"group", --draws various controls at specified coordinates on a surface
}
for _,script_name in ipairs(controls) do  --load each control script
	controls[script_name] = require(PATH..script_name)
	ui["new_"..script_name] = controls[script_name].create --reference to creator function
end

local presets = {} --pre-defined properties from data file to create a control

function ui.load_data(file)
	--define environment for data file
	local env = {}
	setmetatable(env, { __index = function(_, name)
		if controls[name] then
			return function(properties)
				local id = properties.id
				assert(type(id)=="string", "Bad property id to '"..name.."' (string expected)")
				assert(not presets[id], "Bad property id to '"..name.."', must be a unique string")
				
				properties.id = nil --no longer needed
				properties.type = name --overwrites any existing value
				presets[id] = properties
			end
		else return function() end end --ignore anything else
	end})
	
	--load specified ui data file
	local chunk = sol.main.load_file(file)
	assert(chunk, "Unable to load file in 'load_data': "..file)
	setfenv(chunk, env)
	chunk()
end
ui.load_data(PATH.."ui.dat") --load the default ui.dat data file

function ui.create_preset(id, width, height)
	assert(type(id)=="string", "Bad argument #1 to 'create_preset' (string expected)")
	local properties = presets[id]
	assert(properties, "Bad argument #1 to 'create_preset', preset not found: "..id)
	
	return ui["new_"..properties.type](properties, width, height)
end

return ui

--[[ Copyright 2018 Llamazing
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
