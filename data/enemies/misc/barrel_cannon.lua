local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local delay
local frequency
enemy.immobilize_immunity = true

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_invincible()
  enemy:set_damage(1)
  frequency = 3000
  delay = 0
  if enemy:get_property("frequency") then frequency = enemy:get_property("frequency") end
  if enemy:get_property("delay") then delay = enemy:get_property("delay") end
  enemy.shooting_disabled = false
  enemy.projectile_breed = "misc/arrow_4"
end


function enemy:on_restarted()
  sol.timer.start(enemy, delay, function()
    sol.timer.start(enemy, frequency, function()
      if not enemy.shooting_disabled then enemy:shoot() end
      return true
    end)
  end)
end

function enemy:shoot()
  sprite:set_animation("shooting", function() sprite:set_animation("walking") end)
  local direction = sprite:get_direction()
  local dx = {[0] = 16,[1] = 0, [2] = -16, [3] = 0 }
  local dy = {[0] = 0,[1] = -16, [2] = 0, [3] = 16 }
  local arrow = enemy:create_enemy({
    x = dx[direction],
    y = dy[direction],
    direction = direction,
    breed = enemy.projectile_breed
  })
  arrow:go(direction)
end