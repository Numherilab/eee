local enemy = ...

local behavior = require("enemies/lib/soldier")

enemy.height = 16

local properties = {
  main_sprite = "enemies/" .. enemy:get_breed(),
  sword_sprite = "enemies/" .. enemy:get_breed() .. "_weapon",
  life = 4,
  damage = 2,
  normal_speed = 16,
  faster_speed = 55,
  distance = 100,
}

behavior:create(enemy, properties)

enemy:set_dying_sprite_id("enemies/enemy_killed_ko")