local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")
enemy.immobilize_immunity = true
enemy.lighting_effect = 1
enemy.height = 16

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  hurt_style = "monster",
  life = 9,
  damage = 4,
  normal_speed = 10,
  faster_speed = 65,
  detection_distance = 80,
  movement_create = function()
    local m = sol.movement.create("random")
    return m
  end,
  must_be_aligned_to_attack = false,
  push_hero_on_sword = false,
  pushed_when_hurt = false,
  wind_up_time = 1000,

  has_teleport = true,
  teleport_distance = 60,
  teleport_cooldown = 4500,
  invincible_while_charging_teleport = true,
  teleport_length = 120,
  time_phased_out = 3000,
  teleport_sound = "fire_burst_2",

  has_summon_attack = true,
  summon_attack_distance = 400,
  summon_attack_cooldown = 4000,
  summon_attack_wind_up_time = 500,
  summoning_wind_up_sound = "crackle1",
  summoning_sound = "fire_burst_3",
  summon_breed = "misc/fire_blast",
  summon_breed_damage = 4,
  summon_group_size = 2,
  summon_group_delay = 300,
  protected_while_summoning = true,

  has_dash_attack = true,
  dash_attack_distance = 130,
  dash_attack_cooldown = 12000,
  dash_attack_direction = "target_hero",
  dash_attack_length = 96,
  dash_attack_speed = 120,
  dash_attack_wind_up = 600,
  dash_attack_sound = "running",
  


}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)

enemy:register_event("on_created", function()
  enemy:set_obstacle_behavior("flying")
  enemy:set_layer_independent_collisions(true)
end)