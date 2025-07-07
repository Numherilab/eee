local enemy = ...


local behavior = require("enemies/lib/toward_hero_octorok")

enemy.height = 24

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 8,
  damage = 2,
  normal_speed = 35,
  faster_speed = 50,
  hurt_style = "normal",
  size_x = 40,
  size_y = 24,
  detection_distance = 125,
  push_hero_on_sword = true,
  pushed_when_hurt = false,
  projectile_breed = "misc/big_stone",
  shooting_frequency = 800
}

behavior:create(enemy, properties)