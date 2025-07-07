-- Lua script of map oakhaven/west_coast.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  if game:get_value("westoak_tollbridge_switch_activated") == true then
    for tile in map:get_entities("tollbridge_") do
      tile:set_enabled(true)
    end
    paytollbridge_sensor:set_enabled(false)
  end

  --put Hazel Ally on the map
  if game:get_value("hazel_is_currently_following_you") and game:get_value("spoken_to_hazel_south_gate") then
    hazel:set_enabled(true)
  end
end)


function paytollbridge_sensor:on_activated()
  game:start_dialog("_oakhaven.npcs.westoak.tollbridge.1", function(answer)
    if answer == 3 then
      game:remove_money(5)
      game:start_dialog("_oakhaven.npcs.westoak.tollbridge.2")
    end --end of answering
  end)
end

function tollbridgeswitch:on_activated()
  game:set_value("westoak_tollbridge_switch_activated", true)
  paytollbridge_sensor:set_enabled(false)
  for tile in map:get_entities("tollbridge_") do
    tile:set_enabled(true)
  end
end

for sensor in map:get_entities("ssg_sensor") do
function sensor:on_activated() hero:save_solid_ground() end
end

for sensor in map:get_entities("rsg_sensor") do
function sensor:on_activated() hero:reset_solid_ground() end
end