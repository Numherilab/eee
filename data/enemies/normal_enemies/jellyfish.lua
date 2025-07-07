local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")
enemy.height = 24

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  hurt_style = "monster",
  life = 28,
  damage = 20,
  normal_speed = 20,
  faster_speed = 30,
  detection_distance = 140,
  must_be_aligned_to_attack = false,
  push_hero_on_sword = false,
  pushed_when_hurt = false,
  wind_up_time = 1000,

  --Attacks--
  has_airstrike_attack = true,
  airstrike_breed = "misc/lightning_strike",
  airstrike_lag = 300,
  airstrike_attack_cooldown = 2000,
  airstrike_attack_distance = 139,
  airstrike_damage = 30,
--[[
  has_radial_attack = true,
  radial_attack_projectile_breed = "misc/jelly_needle",
  radial_attack_cooldown = 4500,
  radial_attack_distance = 70,
  radial_attack_num_projectiles = 8,
  radial_attack_stop_while_charging = true,
--  radial_attack_projectiles_go_through_walls = true,
--]]

}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)

enemy:register_event("on_created", function()
  enemy:set_obstacle_behavior("flying")
  enemy:set_layer_independent_collisions(true)
end)