local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")
enemy.height = 24

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  hurt_style = "monster",
  life = 16,
  damage = 10,
  normal_speed = 20,
  faster_speed = 35,
  detection_distance = 126,
  must_be_aligned_to_attack = false,
  push_hero_on_sword = false,
  pushed_when_hurt = false,
  wind_up_time = 1000,

  --Attacks--
  has_airstrike_attack = true,
  airstrike_breed = "misc/falling_rock",
  airstrike_lag = 1,
  airstrike_sound="jump",
  airstrike_attack_cooldown = 2000,
  airstrike_attack_distance = 125,

}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)

enemy:register_event("on_created", function()
--  enemy:set_obstacle_behavior("flying")
  enemy:set_layer_independent_collisions(true)
end)

function enemy:on_dead()
  random = math.random(100)
  if random < 35 then
    local map = enemy:get_map()
    local x, y, layer = enemy:get_position()
    map:create_pickable{
     layer = layer,
     x = x,
     y = y,
     treasure_name = "geode",
     treasure_variant = 2,
     }
  end
end