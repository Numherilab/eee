local map = ...
local game = map:get_game()

map:register_event("on_started", function()

  for blades in map:get_entities("windmill_blades") do
    local sprite = blades:get_sprite()
    sol.timer.start(map, 180, function()
      sprite:set_rotation(sprite:get_rotation() + math.rad(3))
      return true
    end)
    sprite:set_shader(sol.shader.create("noise_reducer"))
  end

end)

for fire_sensor in map:get_entities"fire_sensor" do
function fire_sensor:on_collision_fire()
  if fire_sensor.lit then return end
  fire_sensor.lit = true
  map:get_entity("torch_" .. fire_sensor:get_name()):set_enabled(true)
  map.fire_statues_lit = (map.fire_statues_lit and map.fire_statues_lit + 1) or 1
  if map.fire_statues_lit == 3 then
    map:focus_on(map:get_camera(), windmill_door, function()
      map:open_doors("windmill_door")
    end)
  end
end
end
