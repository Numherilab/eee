local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")
enemy.immobilize_immunity = true
enemy.height = 16

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  hurt_style = "boss",
  life = 25,
  damage = 8,
  normal_speed = 20,
  faster_speed = 55,
  detection_distance = 300,
  movement_create = function()
    local m = sol.movement.create("random")
    return m
  end,
  must_be_aligned_to_attack = false,
  push_hero_on_sword = false,
  pushed_when_hurt = false,
  wind_up_time = 1000,

  --Attacks--
  has_melee_attack = true,
  melee_attack_wind_up_time = 500,
  melee_distance = 70,
  melee_attack_cooldown = 3500,
  melee_attack_sound = "sword2",
  attack_sprites = {"enemies/misc/air_slash"},

  has_ranged_attack = true,
  ranged_attack_distance = 170,
  ranged_attack_cooldown = 5000,
  ranged_attack_sound = "shoot",
  projectile_breed = "misc/energy_ball_bounce",
  projectile_angle = "straight",
--optional properties for ranged attack are projectile_damage, projectile_split_children, and projectile_num_bounces, if the projectile breed will accept them!

  has_summon_attack = true,
  summon_attack_distance = 200,
  summon_attack_cooldown = 9000,
  summon_attack_wind_up_time = 1000,
  summoning_sound = "charge_1",
  summon_breed = "misc/fire_blast",
  summon_group_size = 5,
  summon_group_delay = 500,
  protected_while_summoning = true,

--  has_orbit_attack = true,
  orbit_attack_distance = 190,
  orbit_attack_cooldown = 7000,
  orbit_attack_sound = "gravel",
  orbit_attack_launch_sound = "shoot",
  orbit_attack_num_projectiles = 5,
  orbit_attack_charge_time = 1000,
  orbit_attack_shoot_delay = 500,
  orbit_attack_projectile_delay = 200,
  orbit_attack_projectile_breed = "misc/energy_ball_small",
  orbit_attack_radius = 16,

--  has_dash_attack = true,
  dash_attack_distance = 150,
  dash_attack_cooldown = 6000,
  dash_attack_direction = "target_hero",
  dash_attack_length = 96,
  dash_attack_speed = 120,
  dash_attack_wind_up = 600,  
  dash_attack_sound = "running",


  has_radial_attack = true,
  radial_attack_projectile_breed = "normal_enemies/bat_1",
  radial_attack_cooldown = 7000,
  radial_attack_distance = 60,
  radial_attack_sound = "dash",
  radial_attack_num_projectiles = 6,
  radial_attack_charging_time = 1500,
  radial_attack_shoot_delay = 500,
  radial_attack_stop_while_charging = true,
  

}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)