local enemy = ...

local behavior = require("enemies/lib/towards_hero")
enemy.height = 16

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 2,
  damage = 1,
  normal_speed = 35,
  faster_speed = 35,
  detection_distance = 16,
}

behavior:create(enemy, properties)

function enemy:on_dead()
  random = math.random(100)
  if random < 15 then
    local map = enemy:get_map()
    local x, y, layer = enemy:get_position()
    map:create_pickable{
     layer = layer,
     x = x,
     y = y,
     treasure_name = "monster_guts",
     treasure_variant = 1,
     }
  end
end
