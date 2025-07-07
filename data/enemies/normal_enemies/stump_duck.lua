local enemy = ...


local behavior = require("enemies/lib/turret")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 10,
  waking_animation = "wake_up",
  awakening_sound = "bush",
  must_be_aligned_to_shoot = true,
}

behavior:create(enemy, properties)