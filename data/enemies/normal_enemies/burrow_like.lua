local enemy = ...

local behavior = require("enemies/lib/underground_random")

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 5,
  damage = 6,
  normal_speed = 30,
  burrow_sound = "burrow4",
  aboveground_callback = function()
    if enemy:get_distance(enemy:get_map():get_hero()) >= 200 then return end
    for i = 1, 4 do
      local stone = enemy:create_enemy{breed = "misc/octorok_stone"}
      stone:go_any_angle(2* math.pi / 8 * (i * 2 + 1))
    end
    sol.audio.play_sound"breaking_stone"
  end
}

behavior:create(enemy, properties)

function enemy:on_dying()
  random = math.random(100)
  if random < 10 then
    local map = enemy:get_map()
    local x, y, layer = enemy:get_position()
    map:create_pickable{
     layer = layer,
     x = x,
     y = y,
     treasure_name = "monster_guts",
     treasure_variant = 1,
     }
  end
end