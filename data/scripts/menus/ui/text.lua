--[[ text.lua
	version 1.0
	17 May 2019
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/
	
	This script creates an ui subcomponent used to draw a single line of text, which is in
	essence a wrapper for a text surface. Unlike a text surface, the text of the component
	is clipped when it exceeds it maximum width and height dimensions.
	
	It is also possible to draw a shadow behind the text, where the text is drawn first in
	one color, shifted over 1 pixel to the left and up, then drawn again using a different
	color.
]]

local util = require"scripts/menus/ui/util"

local control = {}

--methods to inherit from sol.text_surface
local TEXT_SURFACE_METHODS = {
	get_font = true,
	set_font = true,
	get_rendering_mode = true,
	set_rendering_mode = true,
	get_font_size = true,
	set_font_size = true,
	get_text = true,
	set_text = true,
	set_text_key = true,
	get_text_size = "get_size", --text_surface method has different name: "get_size"
}

--multiplication constant to determine vertical or horizontal position based on alignment keyword
local ALIGNMENT_OFFSETS = {
	left = 0,
	center = 0.5,
	right = 1,
	top = 0,
	middle = 0.5,
	bottom = 1,
}

--// Creates a new text control
	--properties (table) - table containing properties defining text behavior
		--font (string) - name of font to use for text
		--font_size (number, positive) - font size to use for text
		--font_color (string or table) - font color of the text when enabled
			--see make_RGB_color() in scripts/menus/ui/util.lua for more info
		--font_color_disabled (string or table, optional) - font color of text when disabled
			--see make_RGB_color() in scripts/menus/ui/util.lua for more info
		--shadow_color (string or table, optional) - font color of text shadow (drawn behind text and offset by 1 pixel), default: shadow not drawn
		--horizontal_alignment (string, optional) - horizontal alignment of text: "left", "center" or "right", default: "left"
		--vertical_alignment (string, optional) - vertical alignment of text: "top", "middle" or "bottom", default: "top"
		--rendering_mode (string, optional) - how text is drawn: "solid" (faster) or "antialiasing" (smoothing effect), default: "solid"
		--text (string, optional) - initial content of text, default: ""
		--text_key (string, optional) - strings.dat key of localized text to use as contents, default: nil (will use text property for contents instead)
	--width (number, positive) - width of the text region in pixels, text is clipped if it extends beyond this dimension
	--height (number, positive) - height of the text region in pixels, text is clipped if it extends beyond this dimension
	--returns the newly created text object (table)
function control.create(properties, width, height)
	local new_control = {} --ui text component to be returned
	
	--settings defined by data file property values and their default values
	local width = tonumber(width) --(number, positive integer) max width of component in pixels
	local height = tonumber(height) --(number, positive integer) max height of component in pixels
	local font = properties.font --(string) name of font to use for text
	local font_size = properties.font_size --(number, positive) font size to use for text
	local font_color --(table, array) RGB color of text when enabled
	local font_color_disabled --(table, array, optional) RGB color of text when disabled, default: font_color also used when disabled
	local shadow_color --(table, array, optional) RGB color of text shadow, default: shadow is not drawn
	local horizontal_alignment = properties.horizontal_alignment or "left" --(string, optional) horizontal alignment of text: "left", "center" or "right", default: "left"
	local vertical_alignment = properties.vertical_alignment or "top" --(string, optional) vertical alignment of text: "top", "middle" or "bottom", default: "top"
	local rendering_mode = properties.rendering_mode or "solid" --(string, optional) how text is drawn: "solid" (faster) or "antialiasing" (smoothing effect), default: "solid"
	local text = properties.text or "" --(string, optional) initial content of text, default: ""
	local text_key = properties.text_key --(string, optional) strings.dat key of localized text to use as contents, default: nil (will use text property for contents instead)
	
	--additional settings
	local text_surface --(sol.text_surface) intermediate text surface that renders the text
	local position = {x=0, y=0} --(table, key/value) movements change the coordinates of this table, which are added as an offset to the component position when drawn
		--x (number, integer) - amount of the horizontal offset in pixels
		--y (number, integer) - amount of the vertical offset in pixels
		--movement (sol.movement or nil) - active movement of the component, if nil then the movement is done
	local is_enabled = true --(boolean) determines color of text, if false then uses disabled color, default: true
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
	
	--validate font
	assert(type(font)=="string", "Bad property font to 'create' (string expected)")
	
	--validate font_size
	if font_size then
		font_size = tonumber(font_size)
		assert(font_size, "Bad property font_size to 'create' (number or nil expected)")
		assert(font_size>0, "Bad property font_size to 'create' (number must be positive)")
	end
	
	--validate font_color
	local err --temporary error message
	font_color, err = util.make_RGB_color(properties.font_color, 3) --don't allow alpha values
	assert(font_color, "Bad property font_color to 'create'"..tostring(err or ''))
	--font_color is now a table with 3 RGB values
	
	--validate font_color_disabled
	if properties.font_color_disabled then
		font_color_disabled, err = util.make_RGB_color(properties.font_color_disabled, 3) --don't allow alpha values
		assert(font_color, "Bad property font_color to 'create'"..tostring(err or ''))
	end --font_color_disabled is now a table with 3 RGB values
	
	--validate shadow_color
	if properties.shadow_color then
		shadow_color, err = util.make_RGB_color(properties.shadow_color, 3) --don't allow alpha values
		assert(shadow_color, "Bad property shadow_color to 'create'"..tostring(err or ''))
	end --shadow_color is now a table with 3 RGB values
	
	--validate horizontal_alignment
	assert(type(horizontal_alignment)=="string", "Bad property horizontal_alignment to 'create' (string or nil expected)")
	assert(ALIGNMENT_OFFSETS[horizontal_alignment], "Bad property horizontal_alignment to 'create', invalid string value: "..horizontal_alignment)
	
	--validate vertical_alignment
	assert(type(vertical_alignment)=="string", "Bad property vertical_alignment to 'create' (string or nil expected)")
	assert(ALIGNMENT_OFFSETS[vertical_alignment], "Bad property vertical_alignment to 'create', invalid string value: "..vertical_alignment)
	
	--validate rendering_mode
	assert(type(rendering_mode)=="string", "Bad property rendering_mode to 'create' (string or nil expected)")
	
	--validate text
	assert(type(text)=="string", "Bad property text to 'create' (string or nil expected)")
	
	--validate text_key
	assert(not text_key or type(text_key)=="string", "Bad property text_key to 'create' (string or nil expected)")
	
	
	--// implementation
	
	text_surface = sol.text_surface.create{
		horizontal_alignment = "left", --always left justified, x offset is added for other horizontal alignment values
		vertical_alignment = "top", --always aligned to top, y offset is added for other vertical alignment values
		font = font,
		rendering_mode = rendering_mode,
		color = font_color,
		font_size = font_size,
		text = text,
		text_key = text_key,
	}
	
	--inherit methods of sol.text_surface
	setmetatable(new_control, { __index = function(self, name)
		local func_name = name --tentative
		if type(TEXT_SURFACE_METHODS[name])=="string" then --value is the name of the text_surface method to use
			func_name = TEXT_SURFACE_METHODS[name]
		end --else if value is true then new_control method and text_surface method have same name
		
		--call the text_surface method, passing any parameters and return its return value(s)
		if TEXT_SURFACE_METHODS[name] then
			return function(_, ...) return text_surface[func_name](text_surface, ...) end
		else return function() end end
	end})
	
	--// Returns size of a given text string
		--txt (string) - text to get the size of
		--returns width and height of text in pixels (number, non-negative integer)
	function new_control:get_predicted_size(txt)
		return sol.text_surface.get_predicted_size(font, font_size, txt)
	end
	
	--// Returns the width and height (number) of the text region in pixels
		--a value of nil indicates to use the entire width/height, respectively
	function new_control:get_size() return width, height end
	
	--// Get/set the font color of the text as 3 RGB values, 0 to 255
	function new_control:get_font_color() return util.make_RGB_color(color) end --returns a copy of color table
	function new_control:set_font_color(value)
		local value, err = util.make_RGB_color(value, 3) --don't allow alpha values
		assert(value, "Bad argument #2 to 'set_font_color'"..tostring(err or ''))
		
		font_color = value --font_color is now a table with 3 RGB values
		
		--text won't change color if it is currently disabled
		if is_enabled or not font_color_disabled then self:set_color(font_color) end
	end
	
	--// Get/set the shadow color of the text as 3 RGB values, 0 to 255
	function new_control:get_shadow_color() return util.make_RGB_color(color) end --returns a copy of color table
	function new_control:set_shadow_color(value)
		local value, err = util.make_RGB_color(value, 3) --don't allow alpha values
		assert(value, "Bad argument #2 to 'set_shadow_color'"..tostring(err or ''))
		
		shadow_color = value --shadow_color is now a table with 3 RGB values
	end
	
	--// Get/set the horizontal alignment (string) of the text
		--possible values are: "left", "center", "right"
	function new_control:get_horizontal_alignment() return horizontal_alignment end
	function new_control:set_horizontal_alignment(keyword)
		assert(type(keyword)=="string", "Bad argument #2 to set_horizontal_alignment' (string expected)")
		assert(ALIGNMENT_OFFSETS[horizontal_alignment], "Bad argument #2 to 'set_horizontal_alignment', invalid string value: "..horizontal_alignment)
		
		horizontal_alignment = keyword
	end
	
	--// Get/set the vertical alignment (string) of the text
		--possible values are: "top", "middle", "bottom"
	function new_control:get_vertical_alignment() return vertical_alignment end
	function new_control:set_vertical_alignment(keyword)
		assert(type(keyword)=="string", "Bad argument #2 to set_vertical_alignment' (string expected)")
		assert(ALIGNMENT_OFFSETS[vertical_alignment], "Bad argument #2 to 'set_vertical_alignment', invalid string value: "..vertical_alignment)
		
		vertical_alignment = keyword
	end
	
	--// Get/set whether the text is enabled, which uses a different font color when disabled
		--value (boolean) - if true then the text is enabled
	function new_control:get_enabled() return is_enabled end
	function new_control:set_enabled(value)
		assert(type(value)=="boolean", "Bad argument #2 to 'set_enabled' (boolean expected)")
		
		if is_enabled ~= value then
			is_enabled = value
			
			if font_color_disabled then
				text_surface:set_color(is_enabled and font_color or font_color_disabled)
			end --don't bother changing color if disabled color is not defined
		end
	end
	
	--// Get/set whether the component should be drawn
		--value (boolean) - component will be drawn if true
	function new_control:get_visible() return is_visible end
	function new_control:set_visible(value)
		assert(type(value)=="boolean", "Bad arguement #1 to 'set_visible' (boolean expected)")
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
	
	--// Draws the text on the specified destination surface
		--dst_surface (sol.surface) - surface on which to draw the text
		--x (number, optional) - x coordinate of where to draw the text
		--y (number, optional) - y coordinate of where to draw the text
	function new_control:draw(dst_surface, x, y)
		if is_visible then
			local x = x + position.x
			local y = y + position.y
			
			local text_width,text_height = text_surface:get_size()
			local horz_align = ALIGNMENT_OFFSETS[horizontal_alignment] --convenience
			local vert_align = ALIGNMENT_OFFSETS[vertical_alignment] --convenience
			
			--draw shadow first if defined
			if shadow_color then
				local orig_color = text_surface:get_color() --save current color
				
				text_surface:set_color(shadow_color)
				text_surface:draw_region(
					math.max((text_width - width)*horz_align, 0),
					math.max((text_height - height)*vert_align, 0),
					math.min(text_width, width),
					math.min(text_height, height),
					dst_surface,
					x + math.max((width - text_width)*horz_align, 0) + 1, --offset 1 pixel right
					y + math.max((height - text_height)*vert_align, 0) + 1 --offset 1 pixel down
				)
				
				text_surface:set_color(orig_color) --restore original color
			end
			
			--draw regular text, color depends on whether it is enabled
			text_surface:draw_region(
				math.max((text_width - width)*horz_align, 0),
				math.max((text_height - height)*vert_align, 0),
				math.min(text_width, width),
				math.min(text_height, height),
				dst_surface,
				x + math.max((width - text_width)*horz_align, 0),
				y + math.max((height - text_height)*vert_align, 0)
			)
		end
	end
	
	return new_control
end

return control

--[[ Copyright 2016-2019 Llamazing
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
