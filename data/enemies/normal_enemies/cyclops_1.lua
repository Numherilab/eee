local enemy = ...


local behavior = require("enemies/lib/hinox")
enemy.height = 16

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 12,
  damage = 11,
  normal_speed = 25,
  faster_speed = 35,
  detection_distance = 96,
}

behavior:create(enemy, properties)


function enemy:on_dying()
  random = math.random(100)
  if random < 25 then
    local map = enemy:get_map()
    local x, y, layer = enemy:get_position()
    map:create_pickable{
     layer = layer,
     x = x,
     y = y,
     treasure_name = "monster_eye",
     treasure_variant = 1,
     }
  elseif random < 45 then
    local map = enemy:get_map()
    local x, y, l = enemy:get_position()
    map:create_pickable{
      x = x, y = y, layer = l, treasure_name = "bomb", treasure_variant = 2
    }
  end
end