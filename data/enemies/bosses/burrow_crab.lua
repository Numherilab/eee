local enemy = ...

local behavior = require("enemies/lib/underground_random")
enemy.height = 24

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 28,
  damage = 8,
  normal_speed = 60,
  push_hero_on_sword = true,
  burrow_sound = "burrow4",
  time_aboveground = 1000,
  burrow_deviation = 200,
  aboveground_callback = function()
    if enemy:get_distance(enemy:get_map():get_hero()) >= 200 then return end
    for i = 1, 8 do
      local stone = enemy:create_enemy{breed = "misc/octorok_stone"}
      stone:go_any_angle(2* math.pi / 16 * i * 3)
    end
    sol.audio.play_sound"breaking_stone"
  end
}

behavior:create(enemy, properties)

