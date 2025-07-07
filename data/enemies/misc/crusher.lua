local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local frequency
enemy.immobilize_immunity = true

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  frequency = enemy:get_property("frequency") or 1000
  enemy:set_life(1)
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_damage(enemy:get_property("damage") or 10)
  enemy:set_attack_consequence("sword", "protected")
  enemy:set_attack_consequence("arrow", "protected")
  enemy:set_attack_consequence("fire", "protected")
  local delay = enemy:get_property("delay") or 0
  sol.timer.start(map, delay, function()
    enemy:extend()
  end)

end


function enemy:on_restarted()

end

function enemy:extend()
  sol.timer.start(map, frequency, function()
    if enemy:get_distance(hero) < 200 then sol.audio.play_sound("click_low") end
    sprite:set_animation("extending", function() sprite:set_animation("extended") enemy:retract() end)
  end) -- end of timer
end

function enemy:retract()
  sol.timer.start(map, frequency, function()
    if enemy:get_distance(hero) < 200 then sol.audio.play_sound("click_low") end
    sprite:set_animation("retracting", function() sprite:set_animation("walking") enemy:extend() end)
  end) -- end of timer
end