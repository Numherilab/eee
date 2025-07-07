local enemy = ...

local behavior = require("enemies/lib/waiting_for_hero")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  asleep_animation = "asleep",
  awaking_animation = "awaking",
  ignore_obstacles = true,
  obstacle_behavior = "flying",
  waking_distance = 150,
  life = 1,
  damage = 1,
  normal_speed = 25,
  faster_speed = 75,

}

behavior:create(enemy, properties)


enemy:set_layer_independent_collisions(true)