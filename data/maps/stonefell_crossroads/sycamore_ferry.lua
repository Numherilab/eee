-- Lua script of map stonefell_crossroads/sycamore_ferry.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  map:cloud_overlay()
  game:set_world_fall_mode(map:get_world(), "fall")

  lily:get_sprite():set_animation("waving")
  if game:get_value("lily_rescued") then
    lily:set_enabled(false)
    for sensor in map:get_entities("lily_attack_sensor") do sensor:remove() end
    for e in map:get_entities("lily_enemy") do e:set_enabled(false) end
  end
end)

local ferry_armed = false
function ferryman:on_interaction()
  local index = game:get_value("merryweather_ferry_dialog_index")
  if index == nil then
    game:start_dialog("_sycamore_ferry.npcs.ferryman.0")
    game:set_value("merryweather_ferry_dialog_index", 1)
    game:set_value("sycamore_ferry_unlocked", true)
  elseif index == 1 then
    game:start_dialog("_sycamore_ferry.npcs.ferryman.1")
  end
  ferry_armed = true
end

function ferry_south_sensor:on_activated()
  if game:get_value("sycamore_ferry_unlocked") or ferry_armed then
    sol.timer.start(map, 500, function()
      map:open_doors("ferry_south_gate")
      for entity in map:get_entities("ferry_north") do entity:remove() end
    end)
  end
end

function ferry_north_sensor:on_activated()
  sol.timer.start(map, 500, function()
    map:open_doors("ferry_north_gate")
    for entity in map:get_entities("ferry_south") do entity:remove() end
  end)
end

function right_knee:on_interaction()
  statue_door:set_enabled(false)
  sol.audio.play_sound"switch_2"
end

--lily rescue
for sensor in map:get_entities("lily_attack_sensor") do
function sensor:on_activated()
  lily:get_sprite():set_animation("waving")
  map:focus_on(map:get_camera(), lily, function()
    game:start_dialog("_sycamore_ferry.npcs.lily.help")
    sensor:remove()
  end)
end
end

for enemy in map:get_entities("lily_enemy") do
function enemy:on_dead()
  if not map:has_entities("lily_enemy") then
    for sensor in map:get_entities("lily_attack_sensor") do sensor:remove() end
    lily:get_sprite():set_animation("stopped")
    hero:freeze()
    hero:set_animation"walking"
    local m = sol.movement.create("target")
    m:set_speed(80)
    m:set_target(lily)
    m:start(hero)
    function m:on_changed() hero:set_direction(m:get_direction4()) end
    sol.timer.start(map, 1000, function()
      game:start_dialog("_sycamore_ferry.npcs.lily.saved", function()
        game:get_item("fast_travel_chart_goatshead_harbor"):set_variant(1)
        hero:unfreeze()
        game:set_value("lily_rescued", true)
      end)
    end)    
  end
end
end

function lily:on_interaction()
  if not game:get_value"lily_rescued" then
    game:start_dialog"_sycamore_ferry.npcs.lily.help"
  else
    game:start_dialog"_sycamore_ferry.npcs.lily.saved_follow_up"
  end
end
