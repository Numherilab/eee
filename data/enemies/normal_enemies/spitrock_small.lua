local enemy = ...


local behavior = require("enemies/lib/turret")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 6,
  damage = 8,
  waking_animation = "awake",
  projectile_breed = "misc/octorok_stone_2",
--  awakening_sound = "gravel",
  must_be_aligned_to_shoot = true,
}

behavior:create(enemy, properties)

function enemy:on_dead()
  random = math.random(100)
  if random < 15 then
    local map = enemy:get_map()
    local x, y, layer = enemy:get_position()
    map:create_pickable{
     layer = layer,
     x = x,
     y = y,
     treasure_name = "geode",
     treasure_variant = 1,
     }
  end
end