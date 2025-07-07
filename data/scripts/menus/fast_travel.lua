local fast_travel_menu = {}

--[[
limestone
spruce_head
ballast_harbor
goatshead
zephyr_bay
oakhaven
ivystump
yarrowmouth
snapmast
kingsdown
--]]

--[[---NOTES:
right now, the way unlocking ports works, you traverse the locations table one by one. If you hit a location you don't have the chart for, you get problems.
--Maybe just build the runes and then later, don't move along the rune table for selection, but move along the locations table, skipping any is_unlocked = false
--]]

local world_map = require"scripts/world_map"
local path_movement = require"scripts/path_movement"
local path_data = require"scripts/menus/fast_travel.dat"

local locations = {
  {name = "ivystump", coordinates = {180, 44}, is_unlocked, map_id = "oakhaven/ivystump_port"},
  {name = "yarrowmouth", coordinates = {299, 67}, is_unlocked, map_id = "Yarrowmouth/juniper_grove"},
  {name = "snapmast", coordinates = {330, 52}, is_unlocked, map_id = "snapmast_reef/snapmast_landing"},
  {name = "oakhaven", coordinates = {118, 102}, is_unlocked, map_id = "oakhaven/port"},
  {name = "goatshead_harbor", coordinates = {262, 138}, is_unlocked, map_id = "goatshead_island/goatshead_harbor"},
  {name = "isle_of_storms", coordinates = {372, 116}, is_unlocked, map_id = "isle_of_storms/isle_of_storms_landing"},
  {name = "kingsdown", coordinates = {319, 109}, is_unlocked, map_id = "Yarrowmouth/kingsdown"},
  {name = "spruce_head", coordinates = {83, 158}, is_unlocked, map_id = "stonefell_crossroads/spruce_head"},
  {name = "limestone_island", coordinates = {250, 200}, is_unlocked, map_id = "new_limestone/limestone_present"},
  {name = "zephyr_bay", coordinates = {315, 153}, is_unlocked, map_id = "stonefell_crossroads/zephyr_bay"},
  {name = "ballast_harbor", coordinates = {346, 184}, is_unlocked, map_id = "ballast_harbor/ballast_harbor"},
}
local DEFAULT_PORT = 8

local ROUTE_COLOR = {90, 200, 240}

local port_rune = sol.sprite.create("menus/maps/port_rune")
local boat = sol.sprite.create"menus/maps/boat"
local route = sol.surface.create()
local port_runes = {}
local current_port = 1
local map_bg = sol.surface.create("menus/maps/overworld_blank.png")
local sea_bg = sol.surface.create()
sea_bg:fill_color{10, 120, 150}
sea_bg:set_opacity(0)
local sprite_list --(table, array) list of landmass sprites and text in draw order (only if visible)

local animation_playing


function fast_travel_menu:greeting()
  local game = sol.main.get_game()
  local location_name = fast_travel_menu:get_current_location_name()
  game:start_dialog("_fast_travel.location_" .. location_name, function()
    -- if you have new charts
    if fast_travel_menu:has_new_charts() then
      fast_travel_menu:unlock_current_map_port()
      game:start_dialog("_fast_travel.ride_question_new_chart", function(answer)
        sol.menu.start(game:get_map(), fast_travel_menu)
      end)
    --if you don't have any new chart
    else
      fast_travel_menu:unlock_current_map_port()
      game:start_dialog("_fast_travel.ride_question", function()
        sol.menu.start(game:get_map(), fast_travel_menu)
      end)
    end
  end)
end


function fast_travel_menu:get_current_location_name()
  local game = sol.main.get_game()
  local location_name
  for i=1, #locations do
    if game:get_map():get_id() == locations[i].map_id then
      location_name = locations[i].name
    end
  end
  return location_name
end


function fast_travel_menu:has_new_charts()
  local new_chart_brought
  local game = sol.main.get_game()
  local known_charts = game:get_value("lily_chart_total") or 0
  local held_charts = 0
  for i=1, #locations do
    if game:has_item("fast_travel_chart_" .. locations[i].name) then held_charts = held_charts + 1 end
  end
  if held_charts > known_charts then new_chart_brought = true end
  game:set_value("lily_chart_total", held_charts)
  return new_chart_brought
end


function fast_travel_menu:unlock_current_map_port()
  local game = sol.main.get_game()
  for i=1, #locations do
    if game:get_map():get_id() == locations[i].map_id then
      local item = game:get_item("fast_travel_chart_" .. locations[i].name)
      item:set_variant(1)
      game:set_value("lily_chart_total", game:get_value("lily_chart_total") + 1)
    end
  end
end


function fast_travel_menu:on_started()
  animation_playing = false
  sea_bg:set_opacity(0)
  sol.main.get_game():get_hud():set_enabled(false)
  local game = sol.main.get_game()
  game:get_hero():freeze()
  game:set_suspended(true)

  sprite_list = world_map:create_sprites(false) --does not use fade-in reveal of new landmasses
  route:clear()

  fast_travel_menu:update_unlocked_locations()
  fast_travel_menu:update_current_port(game:get_value("fast_travel_menu_current_port") or DEFAULT_PORT)
end


function fast_travel_menu:on_finished()
  sol.main.get_game():get_hud():set_enabled(true)
  sprite_list = nil
end


function fast_travel_menu:update_unlocked_locations()
  local game = sol.main.get_game()
  for i=1, #locations do
    locations[i].is_unlocked = game:has_item("fast_travel_chart_" .. locations[i].name)
    if locations[i].is_unlocked then
      port_runes[i] = sol.sprite.create("menus/maps/port_rune")
      if locations[i].name == fast_travel_menu:get_current_location_name() then
        port_runes[i] = sol.sprite.create("menus/maps/port_rune_current")
      end
    end
  end
end


function fast_travel_menu:update_current_port(new_port)
    if port_runes[current_port] then port_runes[current_port]:set_animation("stopped") end
    if port_runes[new_port] then port_runes[new_port]:set_animation("active") end
    current_port = new_port
end


function fast_travel_menu:unlock_all_ports()
  local game = sol.main.get_game()
  for i=1, #locations do
    local item = game:get_item("fast_travel_chart_" .. locations[i].name)
    item:set_variant(1)
    game:set_value("lily_chart_total", (game:get_value("lily_chart_total") or 0) + 1)
  end
end



--========================non-game logic functions=================================================--
--=================================================================================================--


--next or previous UNLOCKED port------
function fast_travel_menu:calculate_next_port(test_port, step)
  local next_port = test_port + step
  if next_port > #locations then next_port = 1 end
  if next_port <= 0 then next_port = #locations end
  if locations[next_port].is_unlocked then
    fast_travel_menu:update_current_port(next_port)
  else fast_travel_menu:calculate_next_port(next_port, step)
  end
end

function fast_travel_menu:confirm_selection()
  local game = sol.main.get_game()
  local port_name = sol.language.get_string("location."..locations[current_port].name)

  if locations[current_port].name == fast_travel_menu:get_current_location_name() then
    game:start_dialog"_fast_travel.already_here"
    return
  end

  game:start_dialog("_game.fast_travel_confirm", port_name, function(answer)
    if answer == 3 then
      sol.audio.play_sound"ok"
      animation_playing = true
--      sol.audio.play_sound"water_flowing_in_2"
      sea_bg:fade_in(15)
      game:set_value("fast_travel_menu_current_port", current_port)
      local departure_port_name = fast_travel_menu:get_current_location_name()
      local path = path_data[departure_port_name]
      and path_data[departure_port_name][locations[current_port].name] or {}

      local movement = path_movement.create{
        object = boat,
        x = path.x,
        y = path.y,
        path = path,
        context = fast_travel_menu,
        speed = 80, --max of 100
        callback = function()
--          sol.menu.stop(self)
          game:get_hero():unfreeze()
          game:set_suspended(false)
          game:get_hero():teleport(locations[current_port].map_id, "fast_travel_destination")
        end,
      }

      local count = 0
      function movement:on_position_changed()
        count = count + 1
        if count <= 2 then
          local x, y = movement:get_xy()
          route:fill_color(ROUTE_COLOR, x, y, 1, 1)
        else count = 0 end
      end

      --Fail fast-travel forbidden challenges
      game.cursed_marble_no_hit_check = false
      game.footrace_timer = nil

    end
  end)
end


function fast_travel_menu:on_command_pressed(command)
  local handled = false
  local game = sol.main.get_game()
  local hero = game:get_hero()
  if command == "attack" or command == "pause" then
    if not animation_playing then
      sol.menu.stop(self)
      hero:unfreeze()
      game:set_suspended(false)
      handled = true
    end

  elseif command == "left" then
    if animation_playing then return end
    sol.audio.play_sound("cursor")
    fast_travel_menu:calculate_next_port(current_port, -1)
    handled = true

  elseif command == "right" then
    if animation_playing then return end
    sol.audio.play_sound("cursor")
    fast_travel_menu:calculate_next_port(current_port, 1)
    handled = true

  elseif command == "action" then
    if not animation_playing then
      fast_travel_menu:confirm_selection()
      handled = true
    else
      game:get_hero():teleport(locations[current_port].map_id, "fast_travel_destination")
    end
  end
  return handled
end

--Avoid analog stick wildly jumping
local joy_avoid_repeat = {-2, -2}
function fast_travel_menu:on_joypad_axis_moved(axis, state)

  local handled = joy_avoid_repeat[axis] == state
  joy_avoid_repeat[axis] = state

  return handled
end

-----Sea Waves Thing?---------
local fog = sol.surface.create("fog/big_water_light.png")
fog:set_blend_mode("blend")
fog:set_opacity(25)
local fog2 = sol.surface.create("fog/big_water_dark.png")
fog2:set_blend_mode("multiply")
fog2:set_opacity(25)
fog2:set_xy(-500,-150)
local fog3 = sol.surface.create("fog/water_squiggles.png")
fog3:set_blend_mode("blend")
fog3:set_opacity(30)
fog3:set_xy(-400,-270)
  function move_fog(fog, angle, distance)
    local m = sol.movement.create("straight")
    m:set_angle(angle)
    m:set_speed(20)
    m:set_max_distance(distance)
    m:start(fog, function() move_fog(fog, angle + math.pi, distance) end)
  end
move_fog(fog, 3, 180)
move_fog(fog2, .3, 270)
move_fog(fog3, -2.2, 220)

function fast_travel_menu:on_draw(dst)
  sea_bg:draw(dst)
  fog:draw(sea_bg)
  fog2:draw(sea_bg)
  fog3:draw(sea_bg)
  map_bg:draw(dst)
  for _,sprite in ipairs(sprite_list or {}) do --landmass sprites and text
    sprite:draw(dst)
  end
  route:draw(dst)
  boat:draw(dst)
  for i=1, #locations do
    if locations[i].is_unlocked then
      port_runes[i]:draw(dst, locations[i].coordinates[1],locations[i].coordinates[2])
    end
  end
end

return fast_travel_menu