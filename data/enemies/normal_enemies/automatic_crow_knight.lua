local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")
enemy.height = 16
enemy.immobilize_immunity = true

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  hurt_style = "normal",
  life = 20,
  damage = 17,
  normal_speed = 15,
  faster_speed = 65,
  detection_distance = 100,
  movement_create = function()
    local m = sol.movement.create("random_path")
    return m
  end,
  must_be_aligned_to_attack = false,
  push_hero_on_sword = true,
  pushed_when_hurt = true,
  wind_up_time = 500,

  --Attacks--
  has_melee_attack = true,
  melee_attack_wind_up_time = 500,
  melee_distance = 65,
  melee_attack_cooldown = 2000,
  melee_attack_sound = "sword2",
  attack_sprites = {"enemies/misc/air_wave"},

}

properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)

-- local enemy = ...


-- local behavior = require("enemies/lib/sentry")
-- enemy.immobilize_immunity = true
-- enemy.height = 16

-- local properties = {
--   sprite = "enemies/" .. enemy:get_breed(),
--   life = 20,
--   damage = 17,
--   normal_speed = 15,
--   faster_speed = 65,
--   detection_distance_facing = 110,
--   detection_distance_away = 74,
--   attack_distance = 55,
--   wind_up_time = 500,
--   attack_sound = "sword2",
--   must_be_aligned_to_attack = false,
--   push_hero_on_sword = true,
-- }

-- behavior:create(enemy, properties)