local enemy = ...

local behavior = require("enemies/lib/waiting_for_hero")
enemy.height = 16

local game = enemy:get_game()
local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  asleep_animation = "asleep",
  awaking_animation = "awaking",
  waking_distance = 75,
  life = 1,
  damage = 1,
  normal_speed = 10,
  faster_speed = 30,
  push_hero_on_sword = true,

}

behavior:create(enemy, properties)