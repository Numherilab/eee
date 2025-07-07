local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")
enemy.immobilize_immunity = true
enemy.height = 24

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  hurt_style = "monster",
  size_x = 48,
  size_y = 48,
  life = 35,
  damage = 10,
  normal_speed = 20,
  faster_speed = 35,
  detection_distance = 190,
  must_be_aligned_to_attack = false,
  push_hero_on_sword = true,
  pushed_when_hurt = false,
  wind_up_time = 1000,

--  has_melee_attack = true,
  melee_distance = 70,
  melee_attack_cooldown = 1800,
  melee_attack_sound = "sword2",
  attack_sprites = {"enemies/misc/air_wave"},

--  has_ranged_attack = true,
  ranged_attack_distance = 130,
  ranged_attack_cooldown = 3000,
  ranged_attack_sound = "shoot",
  projectile_breed = "misc/energy_ball_split",
  projectile_angle = "any",
  projectile_damage = 5,
  projectile_split_children = 5,

--  has_dash_attack = true,
  dash_attack_distance = 140,
  dash_attack_cooldown = 6000,
  dash_attack_direction = "target_hero",
  dash_attack_length = 120,
  dash_attack_speed = 120,
  dash_attack_wind_up = 800,
  dash_attack_sound = "running",

  has_orbit_attack = true,
  orbit_attack_distance = 190,
  orbit_attack_cooldown = 8000,
  orbit_attack_sound = "gravel",
  orbit_attack_num_projectiles = 8,
  orbit_attack_charge_time = 1000,
  orbit_attack_shoot_delay = 500,
  orbit_attack_projectile_delay = 300,
  orbit_attack_projectile_breed = "misc/stone_projectile",
  orbit_attack_radius = 32,

  --Attacks--
  has_airstrike_attack = true,
  airstrike_breed = "misc/falling_rock",
  airstrike_lag = 1,
  airstrike_sound="jump",
  airstrike_attack_cooldown = 4000,
  airstrike_attack_distance = 125,
  airstrike_num_projectiles = 4,
}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)

