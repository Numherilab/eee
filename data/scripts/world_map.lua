--[[ world_map.lua
	version 1.0.1
	24 Aug 2020
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This script manages the world map, utilizing features common to the map pause menu and
	fast travel menus. It maintains a list of savegame variable names associated with each
	individual map/landmass. It generates a complete set of individual landmass sprites by
	parsing the map file at maps/dev/world_map.dat and reading the position of each custom
	entity used. It also facilitates external manipulation of which landmasses are visible
	to the player through the game.world_map table.
	
	Each map landmass has an associated savegame variable to track its visibility and will
	be revealed when the player visits any map associated with a given landmass. There are
	separate savegame variables to track visibility of map text annotations.
	
	    ------------- Possible savegame variable values:
	  S |   |   | R | * Visible means the landmass will appear in the map menu (not
	  a | V | V | e |   necessarily revealed yet)
	  v | i | i | v | * Visited means the player has entered at least one map on the
	  e | s | s | e |   landmass
	    | i | i | a | * Revealed is the fade-in animation that occurs the first time a new
	  V | b | t | l |   landmass is viewed in the map menu
	  a | l | e | e |
	  l | e | d | d |
	----+-----------+
	|nil| 0 | 0 | 0 | --> map landmass not visible
	| 0 | 1 | 0 | 0 | --> map landmass visible, will be revealed next time map is opened
	| 1 | 1 | 0 | 1 | --> map landmass visible and has been revealed
	| 2 | 1 | 1 | 0 | --> map landmass has been visited, will be revealed next time map is opened
	| 3 | 1 | 1 | 1 | --> map landmass has been visited and revealed
	----+-----------+

	Usage:
	local world_map = require"scripts/world_map"
	world_map:get_visible(id); world_map:set_visible(id, boolean)
	world_map:get_visited(id); world_map:set_visited(id, boolean)
	world_map:get_revealed(id); world_map:set_revealed(id, boolean)
--]]

local language_manager = require"scripts/language_manager"

--constants
local WORLD_MAP_ID = "maps/dev/world_map.dat" --map id that contains world map info
local MAP_LIST = {
	--key (string) map_id, value (table, array)
		--index 1 (string) entity names for world_map landmasses; prefix with 'world_map_landmass_' for savegame variable name
		--index 2 (string, optional) entity names name for world_map text; prefix with 'world_map_text_' for savegame variable name
	['new_limestone/new_limestone_island'] = {'limestone_island', 'limestone'},
	['new_limestone/new_limestone_island'] = {'limestone_island', 'limestone'},
	['new_limestone/limestone_present'] = {'limestone_island', 'limestone'},
	['new_limestone/bracken_beach'] = {'limestone_island'},
	['ballast_harbor/ballast_trail'] = {'ballast_island'},
	['ballast_harbor/ballast_harbor'] = {'ballast_island', 'ballast_harbor'},
	['goatshead_island/crabhook_village'] = {'crabhook', 'crabhook'},
	['goatshead_island/goat_hill'] = {'goatshead_island'},
	['goatshead_island/riverbank'] = {'goatshead_island'},
	['goatshead_island/goatshead_harbor'] = {'goatshead_island', 'goatshead'},
	['stonefell_crossroads/sycamore_ferry'] = {'goatshead_island'},
	['stonefell_crossroads/fort_crow'] = {'crow_island', 'fort_crow'},
	['stonefell_crossroads/crow_road'] = {'crow_island'},
	['stonefell_crossroads/crow_arena'] = {'crow_arena'},
	['stonefell_crossroads/lotus_shoal'] = {'lotus_shoal', 'lotus_shoal'},
	['stonefell_crossroads/spruce_head'] = {'spruce_head', 'spruce_head'},
	['stonefell_crossroads/forest_of_tides'] = {'zephyr_bay', 'zephyr_bay'},
	['stonefell_crossroads/zephyr_bay'] = {'zephyr_bay'},
	['stonefell_crossroads/stonefell_crossroads'] = {'stonefell_crossroads'},
	['oakhaven/sunken_palace'] = {'sunken_palace'},
	['oakhaven/sunken_lighthouse'] = {'sunken_palace'},
	['oakhaven/gull_rock'] = {'gull_rock'},
	['oakhaven/west_oak'] = {'oakhaven'},
	['oakhaven/marblecliff'] = {'oakhaven'},
	['oakhaven/marble_summit'] = {'oakhaven', 'marblecliff'},
	['oakhaven/ivystump'] = {'oakhaven', 'ivystump'},
	['oakhaven/ivystump_port'] = {'oakhaven'},
	['oakhaven/port'] = {'oakhaven', 'oakport'},
	['oakhaven/oakhaven'] = {'oakhaven', 'oakhaven'},
	['oakhaven/eastoak'] = {'oakhaven'},
	['oakhaven/veilwood'] = {'oakhaven'},
	['oakhaven/lobb_trail'] = {'lobb_trail'},
	['Yarrowmouth/puzzlewood'] = {'yarrowmouth_island'},
	['Yarrowmouth/yarrowmouth_village'] = {'yarrowmouth_island', 'yarrowmouth'},
	['Yarrowmouth/juniper_grove'] = {'yarrowmouth_island'},
	['Yarrowmouth/tern_marsh'] = {'tern_marsh', 'tern_marsh'},
	['Yarrowmouth/kingsdown'] = {'kingsdown_isle', 'kingsdown_isle'},
	['snapmast_reef/snapmast_landing'] = {'snapmast_landing', 'snapmast_reef'},
	['snapmast_reef/drowned_village'] = {'snapmast_reef'},
	['snapmast_reef/smoldering_rock'] = {'snapmast_reef'},
	['snapmast_reef/snapmast_lighthouse'] = {'snapmast_reef'},
	['isle_of_storms/isle_of_storms_landing'] = {'isle_of_storms', 'isle_of_storms'},
}

local TEXT_SPRITE_IDS = {
	['menus/maps/text/text_top_left'] = { horz = "left", vert = "top" },
	['menus/maps/text/text_top_center'] = { horz = "center", vert = "top" },
	['menus/maps/text/text_top_right'] = { horz = "right", vert = "top" },
	['menus/maps/text/text_middle_left'] = { horz = "left", vert = "middle" },
	['menus/maps/text/text_middle_center'] = { horz = "center", vert = "middle" },
	['menus/maps/text/text_middle_right'] = { horz = "right", vert = "middle" },
	['menus/maps/text/text_bottom_left'] = { horz = "left", vert = "bottom" },
	['menus/maps/text/text_bottom_center'] = { horz = "center", vert = "bottom" },
	['menus/maps/text/text_bottom_right'] = { horz = "right", vert = "bottom" },
}

--local FONT_COLOR = {142, 112, 70}
local FONT_COLOR = {112, 82, 40}

local TEXT_ALIGNMENT = {
	top = 0,
	middle = 0.5,
	bottom = 1,
	left = 1,
	center = 0,
	right = -1,
}

--construct from MAP_LIST data
local LANDMASS_SPRITES = {} --(table, array) add prefix "world_map_landmass_" or "world_map_roads_" to values to get corresponding savegame variable name
local TEXT_SPRITES = {} --(table, array) add prefix "world_map_" to values to get corresponding savegame variable name
for _,info in pairs(MAP_LIST) do
	local landmass_entity = info[1]
	if landmass_entity and not LANDMASS_SPRITES[landmass_entity] then
		table.insert(LANDMASS_SPRITES, landmass_entity)
		LANDMASS_SPRITES[landmass_entity] = true --prevent adding duplicate entries
	end

	local text_entity = info[2]
	if text_entity and not TEXT_SPRITES[text_entity] then
		table.insert(TEXT_SPRITES, text_entity)
		TEXT_SPRITES[text_entity] = true --prevent adding duplicate entries
	end
end

local world_map = {}
local sprite_info --(table, combo) info for all sprites in draw order, also lookup using entitiy_id as key
--NOTE: also contains info for text_surfaces (where property 'text_key' exists and not 'sprite_id')

--// Call one time when script is loaded to lookup sprites and positions from maps/dev/world_map.dat
local function read_world_map()
	sprite_info = {}
	local all_sprites = {} --(table, array) sprite info in order listed in world_map.dat
	--NOTE: temporary, sprite_info table contains final order based on layers
	
	local env = setmetatable({}, {__index = function() return function() end end}) --do nothing for undefined env functions

	function env.custom_entity(properties)
		local entity_id = properties.name
		if not entity_id then return end --ignore any custom entities without an id
		assert(type(entity_id)=="string", "World Map Error: bad value for custom_entity property 'name' (string expected, got "..type(entity_id)..")")

		local sprite_id = properties.sprite
		if not sprite_id then return end --ignore any custom entities without a sprite
		assert(type(sprite_id)=="string", "World Map Error: bad value for custom_entity property 'sprite' (string expected, got "..type(sprite_id)..")")
		assert(sol.main.resource_exists("sprite", sprite_id), "World Map Error: sprite not found: "..sprite_id)

		local x = tonumber(properties.x)
		assert(x, "World Map Error: bad value for custom_entity property 'x' (number expected)")
		local y = tonumber(properties.y)
		assert(y, "World Map Error: bad value for custom_entity property 'y' (number expected)")
		local layer = tonumber(properties.layer)
		assert(layer, "World Map Error: bad value for custom_entity property 'layer' (number expected)")
		
		local text_info = TEXT_SPRITE_IDS[sprite_id]
		if not text_info then --entity is a sprite, store needed info
			local info = {sprite_id=sprite_id, x=x, y=y, layer=layer, entity_id=entity_id}
			table.insert(all_sprites, info)
		else --entity is a text_surface, store needed info
			local id = entity_id:match"^text_(.+)"
			if id then --else invalid id; ignore
				local info = {
					text_key = "menu.map."..id, --strings.dat key
					x = x,
					y = y,
					layer = layer,
					entity_id = entity_id,
					horizontal_alignment = text_info.horz,
					vertical_alignment = text_info.vert,
				}
				table.insert(all_sprites, info)
			end
		end
	end

	local chunk, err = sol.main.load_file(WORLD_MAP_ID)
	setfenv(chunk, env)
	chunk()

	--reorder sprite info in draw order: layer 1 = landmasses, 2 = roads, 3 = text
	for layer=1,3 do
		for _,info in ipairs(all_sprites) do
			if info.layer == layer then
				table.insert(sprite_info, info)
				sprite_info[info.entity_id] = info --reverse lookup using entity_id
			end
		end
	end
end

--// Returns boolean whether landmass will be visible in map menu
function world_map:get_visible(save_var_id)
	local game = sol.main.get_game()
	return not not game:get_value(save_var_id)
end

--// Makes landmass that the player has not yet visited visible next time map menu is opened
	--boolean (boolean, optional) - true makes landmass visible, false makes landmass not visible, default: true
function world_map:set_visible(save_var_id, boolean)
	local game = sol.main.get_game()
	if boolean or boolean==nil then
		if not game:get_value(save_var_id) then game:set_value(save_var_id, 0) end
	else game:set_value(save_var_id, false) end
end

--// Makes the landmass and text (if any) associated with the given map id visible (unvisited and unrevealed) in the world map
	--map_id (string) - map id to reveal the associated landmass and text in map menu
	--boolean (boolean, optional) - true reveals the landmass/text, false hides it, default true
	--returns false if there is not a landmass associated with the given map id, else returns true
	--NOTE: if the associated landmass and/or text is already visible then it has not effect, respectively
function world_map:set_map_visible(map_id, boolean)
	local info = MAP_LIST[map_id]
	if info then
		if info[1] then self:set_visible("world_map_landmass_"..info[1], boolean) end
		if info[2] then self:set_visible("world_map_text_"..info[2], boolean) end
		return true
	else return false end
end

--// Returns boolean whether player has set foot on the landmass
function world_map:get_visited(save_var_id)
	local game = sol.main.get_game()
	local val = game:get_value(save_var_id) or 0
	return val >= 2
end

--// Marks landmass as visited by player, will be visible next time map menu is opened (if not already)
	--boolean (boolean, optional) - true marks landmass as visited, false marks not visited, default: true
function world_map:set_visited(save_var_id, boolean)
	local game = sol.main.get_game()
	local val = game:get_value(save_var_id) or 0
	if boolean or boolean==nil then
		if val < 2 then game:set_value(save_var_id, val+2) end
	elseif val >= 2 then game:set_value(save_var_id, val-2) end
end

--// Returns boolean whether reveal animation has played for given landmass
function world_map:get_revealed(save_var_id)
	local game = sol.main.get_game()
	local val = game:get_value(save_var_id) or 0
	return val % 2 == 1
end

--// Marks landmass as revealed when viewed in map menu for the first time
	--boolean (boolean, optional) - true marks landmass as revealed, false marks not revealed, default: true
function world_map:set_revealed(save_var_id, boolean)
	local game = sol.main.get_game()
	local val = game:get_value(save_var_id) or 0
	if val % 2 == 0 then
		if boolean or boolean==nil then game:set_value(save_var_id, val+1) end
	elseif not boolean then game:set_value(save_var_id, val-1) end
end

--// Reveal or hide full map
	--value (boolean or number, optional) - value to set all world map savegame values to
		--false hides entire map (writes value of false)
		--true reveals entire map (writes value of 3), default
		--0 makes entire map visible, unvisited and to be revealed in map menu
		--1 makes entire map visible, unvisited and revealed in map menu
		--2 makes entire map visible, visited, and to be revealed in map menu
		--3 makes entire map visible, visited and revealed in map menu
function world_map:show_all(value)
	local val_num = tonumber(value)
	assert(not value or value==true or val_num, "Bad argument #2 to 'show_all' (boolean or number or nil expected)")
	
	local game = sol.main.get_game()
	local val --value to set all world map savegame values to
	
	if val_num then
		val_num = math.floor(val_num)
		assert(val_num>=0 and val_num<=3, "Bad argument #2 to 'show_all', number value must be from 0 to 3")
		val = val_num --if value is a valid number, then use that number directly
	else val = value~=false and 3 end --use 3 for values of nil or true, else use false
	
	for _,var_name in ipairs(LANDMASS_SPRITES) do
		local save_var_id = "world_map_landmass_"..var_name
		game:set_value(save_var_id, val)
	end
	
	for _,var_name in ipairs(TEXT_SPRITES) do
		local save_var_id = "world_map_text_"..var_name
		game:set_value(save_var_id, val)
	end
end

function world_map:create_sprites(do_reveal)
	local game = sol.main.get_game()
	assert(game, "Error: cannot start map menu because no game is currently running")
	
	local font, font_size, line_offset = language_manager:get_map_font()
	line_offset = line_offset or font_size --use font size as line offset by default
	
	--keep track of landmass at player's current location
	local map = game:get_map()
	local map_id = map and map:get_id()
	local current_landmass = MAP_LIST[map_id] and MAP_LIST[map_id][1] --(string) landmass id for player's current location
	local current_id --entity_id of player's current location, may be false/nil
	
	
	--## update visibility status for all landmasses & map text
	
	for _,var_name in ipairs(LANDMASS_SPRITES) do
		local landmass_val = game:get_value("world_map_landmass_"..var_name)
		local is_landmass_visible = not not landmass_val
		local is_landmass_visited = (landmass_val or 0) >= 2
		local is_landmass_revealed = (landmass_val or 0) % 2 == 1
		
		local landmass_info = sprite_info["landmass_"..var_name]
		if landmass_info and landmass_info.sprite_id then --must be sprite
			landmass_info.visible = is_landmass_visible
			landmass_info.visited = is_landmass_visited
			landmass_info.revealed = is_landmass_revealed
			
			if current_landmass==var_name then current_id = landmass_info.entity_id end
			
			--so won't be revealed again next time map is opened
			if is_landmass_visible and not is_landmass_revealed and do_reveal then
				self:set_revealed("world_map_landmass_"..var_name)
			end
		end
		
		local roads_info = sprite_info["roads_"..var_name] 
		if roads_info and roads_info.sprite_id then --must be sprite
			roads_info.visible = is_landmass_visible
			roads_info.visited = is_landmass_visited
			roads_info.revealed = is_landmass_revealed
			--note: roads are always visible if corresponding landmass is visible
		end
	end
	
	for _,var_name in ipairs(TEXT_SPRITES) do
		local text_val = game:get_value("world_map_text_"..var_name)
		local is_text_visible = not not text_val
		local is_text_visited = (text_val or 0) >= 2
		local is_text_revealed = (text_val or 0) % 2 == 1
		
		local text_info = sprite_info["text_"..var_name]
		if text_info and text_info.text_key then --must be text_surface
			text_info.visible = is_text_visible
			text_info.visited = is_text_visited
			text_info.revealed = is_text_revealed
			
			--so won't be revealed again next time map is opened
			if is_text_visible and not is_text_revealed and do_reveal then
				self:set_revealed("world_map_text_"..var_name)
			end
		end
		
		local marker_info = sprite_info["marker_"..var_name]
		if marker_info and marker_info.sprite_id then --must be sprite
			marker_info.visible = is_text_visible
			marker_info.visited = is_text_visited
			marker_info.revealed = is_text_revealed
			--note: markers are always visible if corresponding text is visible
		end
	end
	
	
	--## create sprites for visible landmasses & map text
	
	local sprite_list = {} --(table, array) list of visible sprites in draw order
	local to_reveal = {} --(table, array) list of sprites to be revealed
	local unvisited = {} --(table, array) list of unvisited sprites
	
	for _,info in ipairs(sprite_info or {}) do
		if info.visible then
			local sprite_id = info.sprite_id
			local text_key = info.text_key
			if sprite_id then
				local sprite = sol.sprite.create(info.sprite_id)
				sprite:set_xy(info.x, info.y)
				sprite.layer = info.layer
				sprite.revealed = info.revealed
				sprite.visited = info.visited
				sprite.entity_id = info.entity_id
				
				if info.entity_id == current_id then sprite_list.current = sprite end
				
				table.insert(sprite_list, sprite)
				if not info.revealed then table.insert(to_reveal, sprite) end
				if not info.visited then table.insert(unvisited, sprite) end
			elseif text_key then
				--get strings.dat entry and split at line breaks
				local text = sol.language.get_string(info.text_key) or ""
				text = text:gsub("\\n", "\n").."\n" --silly workaround for Solarus issue #468
				
				--split text at line breaks
				local lines = {}
				local max_width = 0
				for line in text:gmatch"([^\n]*)\n" do
					table.insert(lines, line)
					local width,height = sol.text_surface.get_predicted_size("CartographerTiny", 7, line)
					if width > max_width then max_width = width end
				end
				
				local vert_mult = TEXT_ALIGNMENT[info.vertical_alignment] or 0
				local horz_mult = TEXT_ALIGNMENT[info.horizontal_alignment] or 0
				
				for i,line in ipairs(lines) do
					local text_surface = sol.text_surface.create{
						font = font,
						font_size = font_size,
						color = FONT_COLOR,
						horizontal_alignment = info.horizontal_alignment,
						vertical_alignment = info.vertical_alignment,
						text = line,
					}
					local width = sol.text_surface.get_predicted_size("CartographerTiny", 7, line)
					local horz_offset = math.floor((max_width - width)/2)
					text_surface:set_xy(
						info.x + horz_offset*horz_mult,
						info.y + (i-1 - (#lines-1)*vert_mult)*line_offset
					)
					text_surface.layer = info.layer
					text_surface.revealed = info.revealed
					text_surface.visited = info.visited
					text_surface.entity_id = info.entity_id
				
					table.insert(sprite_list, text_surface)
					if not info.revealed then table.insert(to_reveal, text_surface) end
					if not info.visited then table.insert(unvisited, sprite) end
				end
			end
		end
	end
	
	return sprite_list, to_reveal, unvisited
end

--// Update savegame values whenever the player enters an overworld map
local map_meta = sol.main.get_metatable"map"
map_meta:register_event("on_started", function(self)
	local map = self
	local game = map:get_game()
	local map_id = map:get_id()

	local map_info = MAP_LIST[map_id] or {}
	local landmass_save_var = map_info[1]
	local text_save_var = map_info[2]
	
	if landmass_save_var then
		landmass_save_var = "world_map_landmass_"..landmass_save_var
		world_map:set_visited(landmass_save_var)
	end
	
	if text_save_var then
		text_save_var = "world_map_text_"..text_save_var
		world_map:set_visited(text_save_var)
	end
end)

read_world_map() --perform one time only when this script is loaded

return world_map

--[[ Copyright 2019-2020 Llamazing
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
