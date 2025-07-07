local enemy = ...

local behavior = require("enemies/lib/waiting_for_hero")
enemy.height = 16

local game = enemy:get_game()
local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  asleep_animation = "asleep",
  awaking_animation = "awaking",
  waking_distance = 65,
  life = 18,
  damage = 10,
  normal_speed = 10,
  faster_speed = 70,
  push_hero_on_sword = true,
  pushed_when_hurt = false,

}

behavior:create(enemy, properties)

enemy:register_event("on_attacking_hero", function(enemy, hero, enemy_sprite)
  local sprite = enemy:get_sprite()
  hero = game:get_hero()
  hero:start_hurt(enemy, properties.damage)
  sprite:set_animation("attacking")
  sol.timer.start( 300, function()
    sprite:set_animation("walking") end)
end)

function enemy:on_dead()

    local map = enemy:get_map()
    local x, y, layer = enemy:get_position()
    map:create_pickable{
     layer = layer,
     x = x,
     y = y,
     treasure_name = "mandrake_white",
     treasure_variant = 1,
     }
end

enemy.weak_to_fire = true
function enemy:react_to_fire()
  enemy:propagate_fire()
end
