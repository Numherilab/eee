local enemy = ...

local behavior = require("enemies/lib/towards_hero")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 2,
  damage = 1,
  normal_speed = 20,
  faster_speed = 30,
  detection_distance = 16,
  push_hero_on_sword = true,
  pushed_when_hurt = true,
}

behavior:create(enemy, properties)

function enemy:on_dying()
  enemy:explode_into_spores(20)
end