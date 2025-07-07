local enemy = ...

local behavior = require("enemies/lib/zora")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 1,
  damage = 2,
  burrow_sound = "splash",
  obstacle_behavior = "swimming",
  
}

behavior:create(enemy, properties)