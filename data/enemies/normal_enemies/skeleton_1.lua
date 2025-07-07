local enemy = ...

local behavior = require("enemies/lib/towards_hero")
enemy.height = 16

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 3,
  damage = 4,
  normal_speed = 45,
  faster_speed = 55,
  detection_distance = 48,
}

behavior:create(enemy, properties)

function enemy:on_dead()
  random = math.random(100)
  if random < 20 then
    local map = enemy:get_map()
    local x, y, layer = enemy:get_position()
    map:create_pickable{
     layer = layer,
     x = x,
     y = y,
     treasure_name = "monster_bones",
     treasure_variant = 1,
     }
  end
end