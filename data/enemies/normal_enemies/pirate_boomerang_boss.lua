local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")
enemy.height = 16

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  hurt_style = "normal",
  life = 15,
  damage = 2,
  normal_speed = 20,
  faster_speed = 55,
  detection_distance = 100,
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

  has_boomerang_attack = true,
  boomerang_attack_distance = 128,
  boomerang_attack_cooldown = 3000,
  boomerang_wind_up_time = 500,
  boomerang_sprite = "entities/boomerang1",
  boomerang_max_distance = 120,
  boomerang_speed = 150,
  

}
enemy.height = 24

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)

enemy:set_dying_sprite_id("enemies/enemy_killed_ko")