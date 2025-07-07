local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/ranged_attacker")
enemy.height = 18

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 15,
  damage = 8,
  normal_speed = 15,
  faster_speed = 17,
  detection_distance = 125,
  projectile_breed = "misc/energy_ball_split",
  projectile_angle = "any",
  projectile_damage = 2,
  projectile_split_children = 6,
  wind_up_time = 600,
}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)

function enemy:on_dying()
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