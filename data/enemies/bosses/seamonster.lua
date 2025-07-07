local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

function enemy:on_created()

  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:set_invincible(true)

  enemy:set_size(64, 64)
  enemy:set_origin(32, 32)

  enemy:set_obstacle_behavior("swimming")

end


function enemy:on_restarted()
  sol.timer.start(enemy, 1500, function()
    if enemy.surfaced then enemy:attack() return math.random(2999, 7000)
    else return 1500 end
  end)
end

function enemy:surface()
  sprite:set_animation("surfacing", function()
    enemy.surfaced = true
    sprite:set_animation"walking"
    enemy:on_restarted()
  end)
end

function enemy:dive()
  enemy.surfaced = false
  sol.timer.stop_all(enemy)
--  enemy:on_restarted()
  sprite:set_animation("diving", function()
    enemy.surfaced = false
    sprite:set_animation"underwater"
  end)
end


function enemy:attack()
  sprite:set_animation"wind_up"
  sol.audio.play_sound"charge_1"
  sol.timer.start(enemy, 700, function()
    if enemy.surfaced then enemy:breathe_fire() end
  end)
end

--3 -just keeping this pasted here so I can copy it, since my three key is broken
function enemy:breathe_fire()
  local flame_reps = 1
  sol.timer.start(enemy, 1, function()
    sol.audio.play_sound"fire_burst_3"
    if flame_reps < 4 then flame_reps = flame_reps + 1 return 200 end
  end)
  local NUM_FLAMES = 10
  local ATTACK_DURATION = 800
  local angle_variation = math.rad(30)
  local angle = enemy:get_angle(hero)
  for i = 1, NUM_FLAMES do
    sol.timer.start(enemy, math.random(1,ATTACK_DURATION), function()
      
      local flame = enemy:create_enemy{ y = -16, breed = "misc/blue_fire"}
      local m = sol.movement.create"straight"
      m:set_angle(angle + angle_variation - (math.random() * 2 * angle_variation) )
      m:set_speed(100)
      m:set_smooth(false)
      m:set_max_distance(300)
      m:start(flame, function() flame:remove() end)
      function m:on_obstacle_reached() flame:remove() end
    end)
  end

  sol.timer.start(enemy, ATTACK_DURATION, function()
    sprite:set_animation"walking"
  end)
end
