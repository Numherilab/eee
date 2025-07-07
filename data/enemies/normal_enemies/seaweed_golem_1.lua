local enemy = ...

local behavior = require("enemies/lib/towards_hero")
enemy.height = 20

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 12,
  damage = 8,
  normal_speed = 45,
  faster_speed = 65,
  detection_distance = 48,
}

behavior:create(enemy, properties)

function enemy:on_dead()
  random = math.random(100)
  if random < 30 then
    local map = enemy:get_map()
    local x, y, layer = enemy:get_position()
    map:create_pickable{
     layer = layer,
     x = x,
     y = y,
     treasure_name = "monster_eye",
     treasure_variant = 1,
     }
  end
end