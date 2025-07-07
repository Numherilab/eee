-General Ghosts

local enemy = ...

local behavior = require("enemies/lib/underground_toward_hero")
enemy.height = 16

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 8,
  damage = 16,
  normal_speed = 20,
  faster_speed = 50,
  detection_distance = 50,
  time_aboveground = 2000,
  burrow_deviation = 4000,
  movement_create = function()
    local m = sol.movement.create("random")
    return m
  end  
}

behavior:create(enemy, properties)