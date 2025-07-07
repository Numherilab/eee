local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")
enemy.immobilize_immunity = true
enemy.height = 24

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  hurt_style = "monster",
  life = 22,
  damage = 1,
  normal_speed = 15,
  faster_speed = 40,
  detection_distance = 250,
  movement_create = function()
    local m = sol.movement.create("random")
    return m
  end,
  must_be_aligned_to_attack = false,
  push_hero_on_sword = false,
  pushed_when_hurt = false,
  wind_up_time = 1000,

--  has_summon_attack = true,
  summon_attack_distance = 200,
  summon_attack_cooldown = 9000,
  summon_attack_wind_up_time = 1000,
  summoning_sound = "charge_1",
  summon_breed = "misc/steam_attack",
  summon_group_size = 4,
  summon_group_delay = 1000,
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

  has_dash_attack = true,
  dash_attack_distance = 150,
  dash_attack_cooldown = 6000,
  dash_attack_direction = "target_hero",
  dash_attack_length = 96,
  dash_attack_speed = 200,
  dash_attack_wind_up = 900,  
  dash_attack_sound = "cane",

  has_radial_attack = true,
  radial_attack_projectile_breed = "misc/energy_ball_small",
  radial_attack_cooldown = 6000,
  radial_attack_distance = 100,
  radial_attack_sound = "cane",
  radial_attack_rounds = 2,
  radial_attack_round_delay = 700,
  radial_attack_num_projectiles = 9,
  radial_attack_charging_time = 1500,
  radial_attack_shoot_delay = 500,
  radial_attack_stop_while_charging = true,

--  has_flail_attack = true,
  flail_attack_distance = 128,
  flail_attack_cooldown = 9000,
  flail_wind_up_time = 500,
  flail_sprite = "entities/spike_ball",
  flail_radius = 56,
  flail_max_rotations = 2,
  flail_max_distance = 120, flail_speed = 200,
  

}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)

function enemy:on_dying()
  random = math.random(100)
  if random < 10 then
    local map = enemy:get_map()
    local x, y, layer = enemy:get_position()
    map:create_pickable{
     layer = layer,
     x = x,
     y = y,
     treasure_name = "monster_heart",
     treasure_variant = 1,
     }
  end
end