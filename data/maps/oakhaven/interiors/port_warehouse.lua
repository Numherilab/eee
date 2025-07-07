local map = ...
local game = map:get_game()
local switch_count


map:register_event("on_started", function()
  switch_count = 0

  if game:get_value("quest_mayors_dog") and game:get_value("quest_mayors_dog") >= 7 then
    blocker_npc:set_enabled(false)
  end
  if game:get_value("quest_mayors_dog") and game:get_value("quest_mayors_dog") >= 11 then
    encounter_sensor:set_enabled(false)
    litton_enemy:set_enabled(false)
  end
  if game:get_value("oakport_warehouse_barrel_moved") then
    movable_barrel_bottom:set_enabled(false)
    movable_barrel_top:set_enabled(false)
  end

end)


--secret switches
for switch in map:get_entities("switch") do
function switch:on_activated()
  movable_barrel_bottom:set_layer(2)
  sol.audio.play_sound("switch_2")
  sol.audio.play_sound("hero_pushes")
  local m = sol.movement.create("path")
  local m2 = sol.movement.create("path")
  if switch_count == 0 then
    m:set_path{4}
    m2:set_path{4}
  elseif switch_count == 1 then
    m:set_path{4}
    m2:set_path{4}
  elseif switch_count == 2 then
    m:set_path{4,4}
    m2:set_path{4,4}
    game:set_value("oakport_warehouse_barrel_moved", true)
  end
  switch_count = switch_count + 1
  m:start(movable_barrel_bottom, function() movable_barrel_bottom:set_layer(0) end)
  m2:start(movable_barrel_top)
end
end

function encounter_sensor:on_activated()
  if game:get_value("quest_mayors_dog") and game:get_value("quest_mayors_dog") <= 10 then
    game:start_dialog("_oakhaven.npcs.mayors_party.litton.4-encounter")
    encounter_sensor:set_enabled(false)
    litton_blocker:set_enabled(false)
    game:set_value("quest_mayors_dog", 10)
  end
end

function litton_enemy:on_dead()
  hero:freeze()
  bag_top:set_enabled(true)
  dog:set_enabled(true)
  dog:set_layer(2)
  local m = sol.movement.create("jump")
  m:set_direction8(7)
  m:set_distance(48)
  m:set_ignore_obstacles(true)
  sol.audio.play_sound("jump")
  m:start(dog, function()
    dog:set_layer(0)
    m = sol.movement.create("straight")
    m:set_angle(dog:get_angle(from_upstairs))
    m:set_ignore_obstacles(true)
    m:start(dog)
    sol.timer.start(map, 1000, function()
      dog:remove()
      game:set_value("quest_mayors_dog", 11)
      hero:unfreeze()
      game:start_dialog("_oakhaven.observations.misc.dog_went_back")
    end)
  end)
end
