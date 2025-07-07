local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/general_enemy")
enemy.height = 16

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 4,
  damage = 2,
  normal_speed = 16,
  faster_speed = 64,
  detection_distance = 120,
  attack_distance = 55,
  wind_up_time = 450,
  attack_sound = "sword2",
  must_be_aligned_to_attack = false,
  push_hero_on_sword = false,
  must_be_aligned_to_attack = true,

  has_melee_attack = true,
  melee_attack_wind_up_time = 400,
  melee_distance = 75,
  melee_attack_cooldown = 5000,
  melee_attack_sound = "sword2",
  attack_sprites = {"enemies/misc/sword_slash"},

--for circleing hero movement:
  movement_circle_hero = true,
  movement_circle_hero_radius = 54,
    movement_circle_hero_radius_speed = 10,
}


properties_setter:set_properties(enemy, properties)
behavior:create(enemy, properties)
enemy:set_dying_sprite_id("enemies/enemy_killed_ko")

function enemy:on_dead()
  random = math.random(100)
  if random < 35 then
    local map = enemy:get_map()
    local x, y, layer = enemy:get_position()
    map:create_pickable{
     layer = layer,
     x = x,
     y = y,
     treasure_name = "rupee",
     treasure_variant = 1,
     }
  end
end