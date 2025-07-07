local enemy = ...

local behavior = require("enemies/lib/soldier")
enemy.height = 16

local properties = {
  main_sprite = "enemies/" .. enemy:get_breed(),
  sword_sprite = "enemies/" .. enemy:get_breed() .. "_weapon",
  life = 8,
  damage = 4,
  normal_speed = 16,
  faster_speed = 64,
  distance = 100,
}

behavior:create(enemy, properties)
enemy:set_dying_sprite_id("enemies/enemy_killed_ko")

function enemy:on_dead()
  random = math.random(100)
  if random < 35 then
    local map = enemy:get_map()
    local x, y, layer = enemy:get_position()
    map:create_pickable{
     layer = layer,
     x = x,
     y = y,
     treasure_name = "rupee",
     treasure_variant = 2,
     }
  end
end