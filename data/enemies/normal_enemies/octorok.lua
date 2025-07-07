local enemy = ...


local behavior = require("enemies/lib/archer_teleport")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 10,
  damage = 1,
  normal_speed = 35,
  faster_speed = 35,
--  detection_distance = 96,
}

behavior:create(enemy, properties)