local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")
enemy.immobilize_immunity = true
enemy.height = 16

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  hurt_style = "monster",
  life = 40,
  damage = 20,
  normal_speed = 20,
  faster_speed = 85,
  detection_distance = 80,
  movement_create = function()
    local m = sol.movement.create("random")
    return m
  end,
  must_be_aligned_to_attack = false,
  push_hero_on_sword = false,
  pushed_when_hurt = false,
  wind_up_time = 1000,

  has_melee_attack = true,
  melee_attack_wind_up_time = 500,
  melee_distance = 70,
  melee_attack_cooldown = 6000,
  melee_attack_sound = "sword2",
  attack_sprites = {"enemies/misc/air_wave"},

  has_teleport = true,
  teleport_distance = 60,
  teleport_cooldown = 10000,
  invincible_while_charging_teleport = true,
  teleport_length = 120,
  time_phased_out = 4000,

  has_orbit_attack = true,
  orbit_attack_distance = 190,
  orbit_attack_cooldown = 7000,
  orbit_attack_sound = "gravel",
  orbit_attack_launch_sound = "shoot",
  orbit_attack_num_projectiles = 5,
  orbit_attack_charge_time = 1000,
  orbit_attack_shoot_delay = 500,
  orbit_attack_projectile_delay = 200,
--  orbit_attack_projectile_breed = "misc/energy_ball_small",
  orbit_attack_projectile_breed = "normal_enemies/bat_1",
  orbit_attack_radius = 16,

--  has_dash_attack = true,
  dash_attack_distance = 150,
  dash_attack_cooldown = 3000,
  dash_attack_direction = "target_hero",
  dash_attack_length = 96,
  dash_attack_speed = 120,
  dash_attack_wind_up = 600,
  dash_attack_sound = "running",
  


}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)