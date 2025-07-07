local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  map:get_camera():letterbox()
  --steams A start enabled, steams B start disabled
  crow_enemy:set_enabled(false)
  if game:get_value("fort_crow_entry_bridge_activated") == true then bridge:set_enabled(true) end
  if game:get_value("fort_crow_basement_doors_open") == true then map:set_doors_open("basement_door") end
  if game:get_value("fort_crow_front_door_open") == true then map:set_doors_open("front_door") end
  if game:get_value("thyme_defeated") == true then
    for pirate in map:get_entities("sleeping_pirate") do pirate:set_enabled(false) end
  end


--steam timer
  for steam in map:get_entities("steam_b") do steam:set_enabled(false) end

  sol.timer.start(map, 4000, function()
    sol.audio.play_sound("switch_3")
    sol.audio.play_sound("steam_01")
    for steam in map:get_entities("steam") do
      if steam:is_enabled() == true then steam:set_enabled(false)
      else steam:set_enabled(true)
      end
    end
    return true
  end) --end of 4 sec timer a.

end



--save/reset solid ground sensors
for sensor in map:get_entities("ssg_sensor") do
function sensor:on_activated() hero:save_solid_ground() end
end

for sensor in map:get_entities("rsg_sensor") do
function sensor:on_activated() hero:reset_solid_ground() end
end




function trapdoor_switch:on_activated()
  trapdoor_1:set_enabled(false)
  trapdoor_2:set_enabled(false)
end

function bridge_switch:on_activated()
  bridge:set_enabled(true)
  game:set_value("fort_crow_entry_bridge_activated", true)
end

function door_switch:on_activated()
  map:open_doors("basement_door")
  wooden_wall_door:set_enabled(false)
  game:set_value("fort_crow_basement_doors_open", true)
end

function front_door_switch:on_activated()
  map:open_doors("front_door")
  game:set_value("fort_crow_front_door_open", true)
end

function crow_knight_sensor:on_activated()
  if map:get_entities("crow_enemy") ~= nil then
    crow_dummy:set_enabled(false)
    crow_enemy:set_enabled(true)
  end
end
