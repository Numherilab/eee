local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/ranged_attacker")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 7,
  damage = 12,
  normal_speed = 35,
  faster_speed = 35,
  detection_distance = 160,
  projectile_breed = "misc/zora_fire",
  projectile_angle = "any",
}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)

function enemy:on_dying()
  random = math.random(100)
  if random < 20 then
    local map = enemy:get_map()
    local x, y, layer = enemy:get_position()
    map:create_pickable{
     layer = layer,
     x = x,
     y = y,
     treasure_name = "geode",
     treasure_variant = 1,
     }
  end
end