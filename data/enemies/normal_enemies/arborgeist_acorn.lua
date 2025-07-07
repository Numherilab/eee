local enemy = ...

local behavior = require("enemies/lib/melee_attacker")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 6,
  damage = 10,
  normal_speed = 30,
  faster_speed = 45,
  detection_distance = 96,
  attack_distance = 56,
  wind_up_time = 100,
  attack_sound = "bush",
  dying_sprite = "enemies/enemy_killed_small",
}

behavior:create(enemy, properties)

function enemy:on_dead()
  random = math.random(100)
  if random < 5 then
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
