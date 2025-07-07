local enemy = ...

local behavior = require("enemies/lib/waiting_for_hero")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  asleep_animation = "asleep",
  awaking_animation = "awaking",
  waking_distance = 32,
  life = 4,
  damage = enemy:get_property("damage") or 4,
  normal_speed = 25,
  faster_speed = 85,

}

behavior:create(enemy, properties)

enemy:set_property("endless_pursuit", "true")

enemy:set_layer_independent_collisions(true)