local enemy = ...
enemy.immobilize_immunity = true

local behavior = require("enemies/lib/blade_trap")
local game = enemy:get_game()
local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  asleep_animation = "asleep",
  awaking_animation = "awaking",
  life = 1,
  damage = 1,
  normal_speed = 45,
  faster_speed = 170,
  push_hero_on_sword = true,
  pushed_when_hurt = false,
  invincible = true,

}

behavior:create(enemy, properties)