local enemy = ...

local behavior = require("enemies/lib/towards_hero")
enemy.height = 16

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 3,
  damage = 6,
  normal_speed = 25,
  faster_speed = 65,
  detection_distance = 96,
  obstacle_behavior = flying,
  dashing_speed = 100,
  dying_sprite = "enemies/enemy_killed_projectile",
  movement_create = function()
    local m = sol.movement.create("random")
    return m
  end  
}

behavior:create(enemy, properties)

function enemy:on_dead()
  random = math.random(100)
  if random < 10 then
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