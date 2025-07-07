local enemy = ...

local behavior = require("enemies/lib/toward_hero_octorok")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 20,
  damage = 6,
  normal_speed = 15,
  faster_speed = 30,
  detection_distance = 125,
  projectile_breed = "misc/nitrodendron_bomb",
  explosion_consequence = "protected",
}
enemy.height = 16

behavior:create(enemy, properties)

function enemy:on_dying()
  random = math.random(100)
  if random < 8 then
    local map = enemy:get_map()
    local x, y, layer = enemy:get_position()
    map:create_pickable{
     layer = layer,
     x = x,
     y = y,
     treasure_name = "mandrake",
     treasure_variant = 1,
     }
  end
end


enemy.weak_to_fire = true
function enemy:react_to_fire()
  enemy:propagate_fire()
end
