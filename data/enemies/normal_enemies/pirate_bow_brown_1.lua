local enemy = ...


local behavior = require("enemies/lib/archer_dodge")
enemy.height = 16

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 8,
  damage = 8,
  normal_speed = 30,
  faster_speed = 45,
  detection_distance = 96,
  max_dodge_distance = 48,
  attack_sound = "bow",
  projectile_breed = "misc/arrow_4"
}

behavior:create(enemy, properties)
enemy:set_dying_sprite_id("enemies/enemy_killed_ko")

function enemy:on_dead()
  random = math.random(100)
  if random < 30 then
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