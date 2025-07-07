local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")
enemy.height = 16

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  hurt_style = "normal",
  life = 25,
  damage = 1,
  normal_speed = 20,
  faster_speed = 65,
  detection_distance = 150,
  must_be_aligned_to_attack = false,
  push_hero_on_sword = false,
  pushed_when_hurt = true,
  wind_up_time = 700,

  --Attacks--

--  has_ranged_attack = true,
  ranged_attack_distance = 170,
  ranged_attack_cooldown = 5000,
  ranged_attack_sound = "shoot",
  projectile_breed = "misc/energy_ball_bounce",
--optional properties for ranged attack are projectile_damage, projectile_split_children, and projectile_num_bounces, if the projectile breed will accept them!
  projectile_angle = "any",

--  has_summon_attack = true,
  summon_attack_distance = 200,
  summon_attack_cooldown = 9000,
  summon_attack_wind_up_time = 1000,
  summoning_sound = "charge_1",
  summon_breed = "misc/steam_attack",
  summon_group_size = 4,
  summon_group_delay = 1000,
  protected_while_summoning = true,

  has_orbit_attack = true,
  orbit_attack_distance = 190,
  orbit_attack_cooldown = 3500,
  orbit_attack_sound = "gravel",
  orbit_attack_launch_sound = "shoot",
  orbit_attack_num_projectiles = 6,
  orbit_attack_charge_time = 1000,
  orbit_attack_shoot_delay = 500,
  orbit_attack_projectile_delay = 200,
  orbit_attack_projectile_breed = "misc/orange",
  orbit_attack_radius = 16,
  use_projectile_go_method = true,

--  has_dash_attack = true,
  dash_attack_distance = 150,
  dash_attack_cooldown = 3000,
  dash_attack_direction = "target_hero",
  dash_attack_length = 96,
  dash_attack_speed = 120,
  dash_attack_wind_up = 600,
  dash_attack_sound = "running",
 
--  has_teleport = true,
  teleport_distance = 60,
  teleport_cooldown = 10000,
  invincible_while_charging_teleport = true,
  teleport_length = 120,
  time_phased_out = 4000, 


}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)

enemy:set_dying_sprite_id("enemies/enemy_killed_ko")