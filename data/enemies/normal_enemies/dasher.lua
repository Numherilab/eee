local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")
enemy.height = 16

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  hurt_style = "normal",
  life = 7,
  damage = 2,
  normal_speed = 15,
  faster_speed = 40,
  detection_distance = 120,
  must_be_aligned_to_attack = false,
  push_hero_on_sword = false,
  pushed_when_hurt = true,
  wind_up_time = 1000,


  has_dash_attack = true,
  dash_attack_distance = 190,
  dash_attack_cooldown = 3000,
  dash_attack_direction = "target_hero",
  dash_attack_length = 96,
  dash_attack_speed = 130,
  dash_attack_wind_up = 600,  
  dash_attack_sound = "running",
  dash_attack_smooth = true,


}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)