local enemy = ...

local properties_setter = require("enemies/lib/properties_setter")
local behavior = require("enemies/lib/ogre")
enemy.height = 16

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 4,
  damage = 1,
  normal_speed = 15,
  faster_speed = 50,
  detection_distance = 65,
  attack_distance = 55,
  wind_up_time = 600,
  attack_sound = "sword2",
  must_be_aligned_to_attack = false,
  push_hero_on_sword = true,
  attack_sprites = {"enemies/misc/sword_slash"},
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