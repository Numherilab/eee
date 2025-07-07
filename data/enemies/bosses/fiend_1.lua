local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")
enemy.immobilize_immunity = true
enemy.height = 24

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  hurt_style = "monster",
  size_x = 32,
  size_y = 24,
  life = 35,
  damage = 6,
  normal_speed = 35,
  faster_speed = 55,
  detection_distance = 130,
  must_be_aligned_to_attack = false,
  push_hero_on_sword = false,
  pushed_when_hurt = false,
  wind_up_time = 700,

  has_melee_attack = true,
  melee_distance = 70,
  melee_attack_cooldown = 1800,
  melee_attack_sound = "sword2",
  attack_sprites = {"enemies/misc/air_wave"},

  has_ranged_attack = true,
  ranged_attack_distance = 130,
  ranged_attack_cooldown = 3000,
  ranged_attack_sound = "shoot",
  projectile_breed = "misc/energy_ball_black",
  projectile_angle = "any",
  projectile_damage = 5,
  projectile_split_children = 5,

  has_dash_attack = true,
  dash_attack_distance = 150,
  dash_attack_cooldown = 3000,
  dash_attack_direction = "target_hero",
  dash_attack_length = 96,
  dash_attack_speed = 120,
  dash_attack_wind_up = 600,
  dash_attack_sound = "monster_roar_1",

--  has_orbit_attack = true,
  orbit_attack_distance = 190,
  orbit_attack_cooldown = 5000,
  orbit_attack_sound = "gravel",
  orbit_attack_num_projectiles = 4,
  orbit_attack_charge_time = 1000,
  orbit_attack_shoot_delay = 500,
  orbit_attack_projectile_breed = "misc/energy_ball_small",
  orbit_attack_radius = 16,
}


properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)

function enemy:on_dying()
  random = math.random(100)
  if random < 10 then
    local map = enemy:get_map()
    local x, y, layer = enemy:get_position()
    map:create_pickable{
     layer = layer,
     x = x,
     y = y,
     treasure_name = "monster_heart",
     treasure_variant = 1,
     }
  end
end