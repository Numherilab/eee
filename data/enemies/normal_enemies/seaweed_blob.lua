local enemy = ...

local behavior = require("enemies/lib/towards_hero")
enemy.height = 16

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 1,
  damage = 1,
  normal_speed = 20,
  faster_speed = 50,
  detection_distance = 40,
}

behavior:create(enemy, properties)