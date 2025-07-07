--[[ find_prickles.lua
	version 0.1
	12 May 2019
	GNU General Public License Version 3
	author: Llamazing
	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/
	prints coordinates of all tiles matching GROUND_TYPE on a given map(s)
	usage:
	to print info for all maps: sol.main.do_file"scripts/find_prickles"
	to print info for one map: sol.main.load_file"scripts/find_prickles"(map_id)
]]

local args = ...

local all_maps = sol.main.get_resource_ids"map"

local tilesets = {}
local maps = {}

local GROUND_TYPE = "prickles"

--load tileset .dat file to determine ground property of each tile
local function load_tileset(tileset_id)
	local tileset = {}

	local env = {}
	function env.tile_pattern(properties)
		local id = properties.id
		assert(id, "tile pattern without id")

		local ground = properties.ground
		assert(ground, "tile pattern without ground")

		if ground==GROUND_TYPE then --ignore ground properties not matching GROUND_TYPE
			tileset[id] = true --link the color to use with the tile id
		end
	end

	setmetatable(env, {__index = function() return function() end end})

	local chunk = sol.main.load_file("tilesets/"..tileset_id..".dat")
	setfenv(chunk, env)
	chunk()

	return tileset
end

--load map .dat file to get list of tiles used
local function load_map(map_id)
	local map = { tiles = {} }

	local env = {}

	--properties stores the size and coordinates for the map and the tileset used
	function env.properties(properties)
		local x = tonumber(properties.x)
		assert(x, "property x must be a number")
		local y = tonumber(properties.y)
		assert(y, "property y must be a number")

		local width = tonumber(properties.width)
		assert(width, "property width must be a number")
		local height = tonumber(properties.height)
		assert(height, "property height must be a number")

		local tileset = properties.tileset
		assert(tileset, "properties without tileset")

		map.x = x
		map.y = y
		map.width = width
		map.height = height
		map.tileset = tileset
	end

	--each tile defines a size, coordinates and layer as well as the tile id to use
	function env.tile(properties)
		local pattern = properties.pattern --pattern is the tile id
		assert(pattern, "tile without pattern")

		local layer = properties.layer
		assert(layer, "tile without layer")
		layer = tonumber(layer)
		assert(layer, "tile layer must be a number")

		local x = tonumber(properties.x)
		assert(x, "tile x must be a number")
		local y = tonumber(properties.y)
		assert(y, "tile y must be a number")

		local width = tonumber(properties.width)
		assert(width, "tile width must be a number")
		local height = tonumber(properties.height)
		assert(height, "tile height must be a number")

		table.insert(map.tiles, {
			pattern = pattern,
			layer = layer,
			x = x,
			y = y,
			width = width,
			height = height,
		})
	end

	setmetatable(env, {__index = function() return function() end end})

	local chunk, err = sol.main.load_file("maps/"..map_id..".dat")
	setfenv(chunk, env)
	chunk()

	return map
end

local function print_info(map_id)
	local map_list = all_maps
	if map_id then
		assert(type(map_id)=="string", "Bad argument #1 to 'print_info' (string expected)")
		assert(sol.main.resource_exists("map", map_id), "Bad argument #1 to print_info', invalid map: "..map_id)
		map_list = {map_id}
	end

	for _,map_id in ipairs(map_list) do --for each map
		--load map
		local map_data = load_map(map_id) --read all tile data
		maps[map_id] = map_data

		--load tileset for this map if not already loaded
		local tileset_id = map_data.tileset
		local tileset = tilesets[tileset_id] or load_tileset(tileset_id) --read tileset data

		--save relevant tile info
		local tiles = {}
		for _,tile in ipairs(map_data.tiles) do
			local pattern = tile.pattern
			if tileset[pattern] then
				table.insert(tiles, "# "..tostring(tile.x)..", "..tostring(tile.y))
			end
		end

		--print info
		if #tiles > 0 then --this map contains at least one tile of GROUND_TYPE
			print(map_id)
			for _,coords in ipairs(tiles) do print(coords) end
		end
	end
end

print_info(args)
