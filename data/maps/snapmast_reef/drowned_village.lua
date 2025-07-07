-- Lua script of map snapmast_reef/drowned_village.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local switches_pressed

map:register_event("on_started", function()
  require("scripts/fx/sound_atmosphere_manager"):start_atmosphere(map, "rain")
  local world = map:get_world()
  game:set_world_rain_mode(world, "storm")
  switches_pressed = 0
  if game:get_value("snapmast_reef_drawbridge") then
    sol.audio.play_sound("switch")
    for tile in map:get_entities("bridge_a") do
      tile:set_enabled(true)
    end
  end
end)

for switch in map:get_entities("tower_switch") do
  function switch:on_activated()
    sol.audio.play_sound("switch_2")
    switches_pressed = switches_pressed + 1
    if switches_pressed == 2 then
      hero:freeze()
      local camera = map:get_camera()
      local m = sol.movement.create("target")
      m:set_target(camera:get_position_to_track(tower_door))
      m:set_speed(160)
      m:start(camera, function()
        sol.audio.play_sound("secret")
        map:open_doors("tower_door")
        sol.timer.start(map, 500, function()
          m:set_target(camera:get_position_to_track(hero))
          m:set_speed(160)
          m:start(camera, function() hero:unfreeze() camera:start_tracking(hero) end)
        end)
      end)
    end
  end
end

function bridge_switch:on_activated()
  if not game:get_value("snapmast_reef_drawbridge") then
    sol.audio.play_sound("switch")

    map:focus_on(map:get_camera(), bridge_a_1, function()
      for tile in map:get_entities("bridge_a") do
        tile:set_enabled(true)
        map:create_poof(tile:get_position())
      end
      sol.audio.play_sound("secret")
      map:open_doors("tower_door")
    end)
    game:set_value("snapmast_reef_drawbridge", true)
  end
end