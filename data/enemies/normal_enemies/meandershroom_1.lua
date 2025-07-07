local enemy = ...

local behavior = require("enemies/lib/towards_hero")
enemy.height = 20

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 6,
  damage = 1,
  normal_speed = 20,
  faster_speed = 35,
  detection_distance = 16,
  size_x = 32,
  size_y = 24,
  push_hero_on_sword = true,
}

behavior:create(enemy, properties)

function enemy:on_dying()
  enemy:explode_into_spores(29, 24, 2, nil)
end

function enemy:on_dead()
  random = math.random(100)
  if random < 25 then
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