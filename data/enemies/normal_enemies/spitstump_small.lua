local enemy = ...


local behavior = require("enemies/lib/turret")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 4,
  damage = 4,
  waking_animation = "awake",
--  awakening_sound = "gravel",
  must_be_aligned_to_shoot = true,
  min_range = 40,
}

behavior:create(enemy, properties)

function enemy:on_dead()
  random = math.random(100)
  if random < 20 then
    local map = enemy:get_map()
    local x, y, layer = enemy:get_position()
    map:create_pickable{
     layer = layer,
     x = x,
     y = y,
     treasure_name = "mandrake",
     treasure_variant = 1,
     }
  end
end

enemy.weak_to_fire = true
function enemy:react_to_fire()
  enemy:propagate_fire()
end
