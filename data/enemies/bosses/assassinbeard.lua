local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")
enemy.immobilize_immunity = true
enemy.height = 16

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 80,
  damage = 10,
  normal_speed = 16,
  faster_speed = 75,
  hurt_style = "boss",
  detection_distance = 400,
  attack_distance = 65,
  wind_up_time = 450,
  attack_sound = "sword2",
  must_be_aligned_to_attack = false,
--  push_hero_on_sword = true,
  must_be_aligned_to_attack = true,

  has_melee_attack = true,
  melee_attack_wind_up_time = 400,
  melee_distance = 65,
  melee_attack_cooldown = 3000,
  melee_attack_sound = "sword2",
  attack_sprites = {"enemies/misc/sword_slash"},

  has_ranged_attack = true,
  ranged_attack_distance = 190,
  ranged_attack_cooldown = 10000,
  ranged_attack_sound = "hand_cannon",
  projectile_breed = "misc/bomb_any_direction",
  projectile_angle = "any",

  has_teleport = true,
  teleport_distance = 60,
  teleport_cooldown = 10000,
  invincible_while_charging_teleport = true,
  teleport_length = 120,
  time_phased_out = 2000,

  has_radial_attack = true,
  radial_attack_projectile_breed = "misc/blue_fire",
  radial_attack_cooldown = 5000,
  radial_attack_distance = 60,
  radial_attack_sound = "dash",
  radial_attack_num_projectiles = 9,
  radial_attack_charging_time = 1500,
  radial_attack_shoot_delay = 500,
  radial_attack_stop_while_charging = true,

}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)

enemy:set_dying_sprite_id("enemies/enemy_killed_ko")