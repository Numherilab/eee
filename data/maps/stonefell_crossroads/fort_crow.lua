local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  guard_2:set_enabled(false)
  if game:get_value("spiked_crow_ale") then guard_1:set_enabled(false) guard_2:set_enabled(true) end
  if game:get_value("fort_crow_front_door_open") == true then map:set_doors_open("front_door") end
  if game:get_value("thyme_defeated") == true then guard_2:set_enabled(false) end
  if game:get_value("quest_pirate_fort") == 4 then morus:set_enabled(true) end
end)

function enable_sensor_sensor:on_activated()
  map:get_entity("^map_banner_sensor"):set_enabled(true)
  sol.timer.start(map, 1000, function() map:get_entity("^map_banner_sensor"):set_enabled(false) end)
  enable_sensor_sensor:set_enabled(false)
end

function morus:on_interaction()
  game:start_dialog("_oakhaven.npcs.morus.fort.1", function()
    local m = sol.movement.create("path")
    m:set_path{2,2,2,2,2,2,2,2}
    m:set_speed(60)
    m:start(morus, function() morus:remove() end)
    game:set_value("quest_pirate_fort", 5)
    game:set_value("fort_crow_interior_morus_counter", 1)
  end)
end

function bridge_switch:on_activated()
  sol.audio.play_sound"switch"
  map:focus_on(map:get_camera(), bridge_door, function()
    map:open_doors"bridge_door"
  end)
end
