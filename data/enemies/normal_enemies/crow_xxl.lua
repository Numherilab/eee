local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")
enemy.immobilize_immunity = true
enemy.height = 16

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  hurt_style = "normal",
  life = 50,
  damage = 10,
  normal_speed = 20,
  faster_speed = 50,
  detection_distance = 300,
  must_be_aligned_to_attack = false,
  push_hero_on_sword = false,
  pushed_when_hurt = false,
  wind_up_time = 1000,

  --Attacks--
  has_melee_attack = true,
  melee_attack_wind_up_time = 500,
  melee_distance = 70,
  melee_attack_cooldown = 5000,
  melee_attack_sound = "sword2",
  attack_sprites = {"enemies/misc/air_wave"},

--  has_dash_attack = true,
  dash_attack_distance = 150,
  dash_attack_cooldown = 9000,
  dash_attack_direction = "target_hero",
  dash_attack_length = 96,
  dash_attack_speed = 120,
  dash_attack_wind_up = 600,  
  dash_attack_sound = "running",
 
  has_flail_attack = true,
  flail_attack_distance = 128,
  flail_attack_cooldown = 7000,
  flail_wind_up_time = 500,
  flail_sprite = "entities/spike_ball",
  flail_radius = 56,
  flail_max_rotations = 2,
  flail_max_distance = 120, flail_speed = 200,
  

}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)