local enemy = ...

local behavior = require("enemies/lib/run_away_bird")
enemy.immobilize_immunity = true

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  asleep_animation = "asleep",
  awaking_animation = "awaking",
  ignore_obstacles = true,
  obstacle_behavior = "flying",
  waking_distance = 50,
  life = 100,
  damage = 0,
  normal_speed = 75,
  faster_speed = 185,

}

behavior:create(enemy, properties)

function enemy:on_attacking_hero()

end

--enemy:set_layer_independent_collisions(true)