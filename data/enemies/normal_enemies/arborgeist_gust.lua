local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")
enemy.height = 16

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  hurt_style = "normal",
  life = 8,
  damage = 1,
  normal_speed = 5,
  faster_speed = 35,
  detection_distance = 100,
  movement_create = function()
    local m = sol.movement.create("random")
    return m
  end,
  must_be_aligned_to_attack = false,
  push_hero_on_sword = false,
  pushed_when_hurt = false,
  wind_up_time = 800,

  --Attacks--
--  has_ranged_attack = true,
  ranged_attack_distance = 170,
  ranged_attack_cooldown = 5000,
  ranged_attack_sound = "heart",
  projectile_breed = "misc/energy_ball_bounce",
--optional properties for ranged attack are projectile_damage, projectile_split_children, and projectile_num_bounces, if the projectile breed will accept them!
  projectile_angle = "any",

--  has_summon_attack = true,
  summon_attack_distance = 200,
  summon_attack_cooldown = 4000,
  summon_attack_wind_up_time = 1200,
  summoning_sound = "gravel",
  summon_breed = "misc/root_small",
  summon_group_size = 3,
  summon_group_delay = 800,
  protected_while_summoning = true,

  has_orbit_attack = true,
  orbit_attack_distance = 190,
  orbit_attack_cooldown = 7000,
  orbit_attack_sound = "gravel",
  orbit_attack_launch_sound = "shoot_magic",
  orbit_attack_num_projectiles = 5,
  orbit_attack_charge_time = 1000,
  orbit_attack_shoot_delay = 500,
  orbit_attack_projectile_delay = 200,
  orbit_attack_projectile_breed = "misc/energy_ball_small",
  orbit_attack_radius = 16,

}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)

enemy.weak_to_fire = true
function enemy:react_to_fire()
  enemy:propagate_fire()
end
