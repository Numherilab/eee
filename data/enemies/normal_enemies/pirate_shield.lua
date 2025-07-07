local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")
enemy.height = 16

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  hurt_style = "normal",
  life = 15,
  damage = 3,
  normal_speed = 10,
  faster_speed = 35,
  detection_distance = 150,
  must_be_aligned_to_attack = false,
  push_hero_on_sword = false,
  pushed_when_hurt = false,
  wind_up_time = 1000,
  has_shield = true,

  --Attacks--
  has_melee_attack = true,
  melee_attack_wind_up_time = 500,
  melee_distance = 70,
  melee_attack_cooldown = 5000,
  melee_attack_sound = "sword2",
  attack_sprites = {"enemies/misc/sword_slash"},

--  has_dash_attack = true,
  dash_attack_distance = 150,
  dash_attack_cooldown = 6000,
  dash_attack_direction = "target_hero",
  dash_attack_length = 96,
  dash_attack_speed = 120,
  dash_attack_wind_up = 600,  
  dash_attack_sound = "running",

}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)
enemy:set_dying_sprite_id("enemies/enemy_killed_ko")

function enemy:hit_by_toss_ball()
  enemy.shield_down = true
  enemy:restart()
end
