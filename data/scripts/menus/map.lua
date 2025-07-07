local multi_events = require"scripts/multi_events"
local world_map = require"scripts/world_map"

--constants
local REVEAL_DELAY = 200 --delay time (in msec) before revealing new landmasses
local FADE_IN_DELAY = 40 --delay time (in msec) between fade in frames when revealing a landmass
local UNVISITED_MODULATION = {210,235,255,255} --modulation color to darken unvisited landmasses

--adjust size and position of overworld maps to fit hand-drawn map dimensions
local MAP_LOCATIONS = {
	['new_limestone/limestone_present'] = {x=227, y=167, width=43, height=30},
	['new_limestone/new_limestone_island'] = {x=227, y=167, width=43, height=30},
	['new_limestone/bracken_beach'] = {x=187, y=163, width=40, height=20},
	['ballast_harbor/ballast_trail'] = {x=274, y=159, width=42, height=28},
	['ballast_harbor/ballast_harbor'] = {x=316, y=154, width=48, height=31},
	['goatshead_island/crabhook_village'] = {x=157, y=111, width=32, height=23},
	['goatshead_island/goat_hill'] = {x=283, y=111, width=31, height=12},
	['goatshead_island/riverbank'] = {x=281, y=123, width=34, height=17},
	['goatshead_island/goatshead_harbor'] = {x=229, y=112, width=52, height=27},
	['stonefell_crossroads/sycamore_ferry'] = {x=189, y=106, width=34, height=57},
	['stonefell_crossroads/fort_crow'] = {x=53, y=161, width=29, height=34},
	['stonefell_crossroads/crow_road'] = {x=82, y=174, width=52, height=22},
	['stonefell_crossroads/lotus_shoal'] = {x=107, y=134, width=80, height=40},
	['stonefell_crossroads/spruce_head'] = {x=80, y=137, width=32, height=26},
	['stonefell_crossroads/forest_of_tides'] = {x=229, y=139, width=55, height=21},
	['stonefell_crossroads/zephyr_bay'] = {x=284, y=140, width=31, height=19},
	['stonefell_crossroads/stonefell_crossroads'] = {x=180, y=83, width=64, height=28},
	['oakhaven/gull_rock'] = {x=41, y=103, width=44, height=22},
	['oakhaven/west_oak'] = {x=57, y=59, width=21, height=44},
	['oakhaven/marblecliff'] = {x=58, y=40, width=41, height=28},
	['oakhaven/marble_summit'] = {x=66, y=23, width=32, height=17},
	['oakhaven/ivystump'] = {x=144, y=23, width=23, height=23},
	['oakhaven/ivystump_port'] = {x=167, y=29, width=14, height=17},
	['oakhaven/port'] = {x=78, y=68, width=62, height=35},
	['oakhaven/lobb_trail'] = {x=186, y=55, width=9, height=24},
	['oakhaven/oakhaven'] = {x=99, y=37, width=41, height=31},
	['oakhaven/eastoak'] = {x=140, y=74, width=40, height=30},
	['oakhaven/veilwood'] = {x=140, y=46, width=45, height=28},
	['Yarrowmouth/puzzlewood'] = {x=195, y=37, width=50, height=47},
	['Yarrowmouth/yarrowmouth_village'] = {x=243, y=43, width=36, height=36},
	['Yarrowmouth/juniper_grove'] = {x=279, y=48, width=34, height=27},
	['Yarrowmouth/tern_marsh'] = {x=245, y=79, width=41, height=28},
	['Yarrowmouth/kingsdown'] = {x=286, y=69, width=37, height=38},
	['snapmast_reef/snapmast_landing'] = {x=323, y=54, width=22, height=56},
	['snapmast_reef/drowned_village'] = {x=345, y=44, width=43, height=22},
	['snapmast_reef/smoldering_rock'] = {x=380, y=28, width=14, height=16},
	['snapmast_reef/snapmast_lighthouse'] = {x=330, y=35, width=15, height=17},
	['isle_of_storms/isle_of_storms_landing'] = {x=371, y=105, width=26, height=21},
}

local map_screen = {x=0, y=0}
multi_events:enable(map_screen)

local sprite_list --(table, array) list of sprites in draw order (unrevealed landmasses not included)
local map_bg --(sol.surface) blank map with no landmasses
local marker = sol.sprite.create("menus/maps/marker_icon")
marker:set_animation("active")
local pos_x, pos_y


--// Gets/sets the x,y position of the menu in pixels
function map_screen:get_xy() return self.x, self.y end
function map_screen:set_xy(x, y)
  x = tonumber(x)
  assert(x, "Bad argument #2 to 'set_xy' (number expected)")
  y = tonumber(y)
  assert(y, "Bad argument #3 to 'set_xy' (number expected)")

  self.x = math.floor(x)
  self.y = math.floor(y)
end

--retrieve visible landmass sprites from world_map script
function map_screen:on_started()
  local game = sol.main.get_game()
  assert(game, "Error: cannot start map menu because no game is currently running")

  local map = game:get_map()
  assert(map, "Error: cannot start map menu because no map is currently active")
  map_id = map:get_id()

  map_bg = sol.surface.create("menus/maps/overworld_blank.png")

  local map_loc = MAP_LOCATIONS[map_id]
  if map_loc then
    local map_width, map_height = map:get_size()
    local hero = game:get_hero()
    local hero_x, hero_y = hero:get_position()

    pos_x = map_loc.x + map_loc.width*hero_x/map_width
    pos_y = map_loc.y + map_loc.height*hero_y/map_height
  else
    pos_x = nil
    pos_y = nil
  end

  local sprites, to_reveal, unvisited = world_map:create_sprites(true) --reveal new landmasses
  sprite_list = sprites

  --do reveal fade-in animation if any new landmasses
  if #to_reveal > 0 then
    for _,sprite in ipairs(to_reveal) do
      sprite:set_opacity(0) --hide until fade-in starts
    end

    sol.timer.start(self, REVEAL_DELAY, function()
      --TODO play reveal map sound
      for _,sprite in ipairs(to_reveal) do
        sprite:fade_in(FADE_IN_DELAY)
      end
    end)
  end

  --darken unvisited landmasses
  if #unvisited > 0 then
    for _,sprite in ipairs(unvisited) do
      if sprite.layer==1 then sprite:set_color_modulation(UNVISITED_MODULATION) end --landmasses are layer 1
    end
  end
end

--// Called when pause menu is closed, remove sprites from memory
function map_screen:on_pause_menu_finished()
  sprite_list = nil
end

function map_screen:on_draw(dst_surface)
  map_bg:draw(dst_surface, self.x, self.y)
  for _,sprite in ipairs(sprite_list or {}) do
    sprite:draw(dst_surface, self.x, self.y)
  end
  if pos_x then marker:draw(dst_surface, self.x+pos_x, self.y+pos_y) end
end

return map_screen
