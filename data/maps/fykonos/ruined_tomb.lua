local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  if game:get_value"fykonos_defeated_ophira" then
    map:close_doors"stone_door"
    for enemy in map:get_entities_by_type"enemy" do
      if enemy:get_breed() == "normal_enemies/ophira_goblin" then enemy:remove() end
    end
  end
end)

for fire_sensor in map:get_entities"fire_sensor" do
function fire_sensor:on_collision_fire()
  if fire_sensor:get_name() == "fire_sensor_1" then torch_1:set_enabled() end
  if fire_sensor:get_name() == "fire_sensor_2" then torch_2:set_enabled() end
  if torch_1:is_enabled() and torch_2:is_enabled() and not game:get_value"fykonos_defeated_ophira" then
    sol.audio.play_sound"secret"
    map:open_doors"stone_door"
  end
end
end
