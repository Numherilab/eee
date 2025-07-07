local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")
enemy.height = 16

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 10,
  damage = 4,
  normal_speed = 5,
  faster_speed = 15,
  detection_distance = 140,
  attack_distance = 55,
  wind_up_time = 500,
  attack_sound = "sword2",
  must_be_aligned_to_attack = false,
--  push_hero_on_sword = true,
  must_be_aligned_to_attack = false,


  has_ranged_attack = true,
  ranged_attack_distance = 190,
  ranged_attack_cooldown = 3000,
  ranged_attack_sound = "bow",
  projectile_breed = "misc/arrow_any_direction",
  projectile_angle = "any",

--for circleing hero movement:
  movement_circle_hero = true,
  movement_circle_hero_radius = 54,
    movement_circle_hero_radius_speed = 10,
}

properties_setter:set_properties(enemy, properties)
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
     treasure_variant = 3,
     }
  end
end