local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")
enemy.height = 20

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  hurt_style = "boss",
  life = 20,
  damage = 8,
  normal_speed = 20,
  faster_speed = 55,
  detection_distance = 150,
  must_be_aligned_to_attack = false,
  push_hero_on_sword = false,
  pushed_when_hurt = false,
  wind_up_time = 1000,

  --Attacks--
  has_melee_attack = true,
  melee_attack_wind_up_time = 600,
  melee_distance = 70,
  melee_attack_cooldown = 5000,
  melee_attack_sound = "sword2",
  attack_sprites = {"enemies/misc/air_slash"},

  has_ranged_attack = true,
  ranged_attack_distance = 170,
  ranged_attack_cooldown = 5000,
  ranged_attack_sound = "shoot",
  projectile_breed = "misc/energy_ball_bounce",
  projectile_angle = "any",
--optional properties for ranged attack are projectile_damage, projectile_split_children, and projectile_num_bounces, if the projectile breed will accept them!

--  has_summon_attack = true,
  summon_attack_distance = 200,
  summon_attack_cooldown = 9000,
  summon_attack_wind_up_time = 1000,
  summoning_sound = "charge_1",
  summon_breed = "misc/skeleton_hand",
  summon_group_size = 5,
  summon_group_delay = 1000,
  protected_while_summoning = true,

  has_dash_attack = true,
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

function enemy:on_dying()
  random = math.random(100)
  if random < 35 then
    local map = enemy:get_map()
    local x, y, layer = enemy:get_position()
    map:create_pickable{
     layer = layer,
     x = x,
     y = y,
     treasure_name = "monster_bones",
     treasure_variant = 2,
     }
  end
end
