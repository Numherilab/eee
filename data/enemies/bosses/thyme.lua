--[[local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local teleporting = false
local can_teleport = true
local teleport_frequency = 11000
local shooting_frequency = 4000
local thyme_speed = 55
local can_shoot = true
 
function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(100)
  enemy:set_damage(1)
  enemy:set_attack_consequence("explosion", "protected")
  enemy:set_hurt_style("boss")
end
 
function enemy:on_restarted()
  enemy:check_hero() 
end
 
function enemy:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end
 
function enemy:check_hero()
  --teleport
  if enemy:get_distance(hero) < 75 and can_teleport and not can_shoot then enemy:teleport() end --the boss teleports if you get too close
  if enemy:get_distance(hero) < 75 and can_shoot and not teleporting then enemy:shoot() end
 
  if not teleporting then --teleporting has a movement and we don't want the movements to conflict
    local hero_angle = enemy:get_angle(hero) --gets angle toward hero
    local mov_angle = hero_angle + math.pi --the angle opposite of the hero
    enemy:stop_movement()
    local m = sol.movement.create("straight")
    m:set_angle(mov_angle)
    m:set_speed(thyme_speed)
    m:set_max_distance(0)
    m:set_smooth(true)
    m:start(enemy)
  end
  sol.timer.start(enemy, 100, function() enemy:check_hero() end)
end
 
function enemy:teleport()
  enemy:set_attack_consequence("sword", "protected") --while he's preparing to teleport, he's invincible
  enemy:set_attack_consequence("arrow", "protected")
  teleporting = true
  can_teleport = false --we don't want him to teleport again right away
  sol.timer.start(map, teleport_frequency, function() can_teleport = true end) --when he can teleport again (in 10 seconds)
  enemy:stop_movement()
  sprite:set_animation("teleport_charge", function()
    local x, y, layer = enemy:get_position()
    map:create_explosion({ x = x, y = y, layer = layer})
    sol.audio.play_sound("explosion")
    sprite:set_animation("teleporting")
    local t = sol.movement.create("straight")
    local telang = enemy:get_angle(480, 240)
    t:set_angle(telang)
    t:set_speed(200)
    t:set_smooth()
    t:set_max_distance(180)
    t:start(enemy)
    sol.timer.start(enemy, 1500, function()
      x, y, layer = enemy:get_position()
      map:create_explosion({ x = x, y = y, layer = layer})
      sol.audio.play_sound("explosion")
      enemy:set_attack_consequence("sword", 1)
      enemy:set_attack_consequence("arrow", 1)
      sprite:set_animation("walking")
      enemy:check_hero()
      teleporting = false
    end) --end of after teleporting timer
 
  end) --end of after charging animation
end

function enemy:shoot()
-- print("shooting")
  can_shoot = false
  sol.timer.start(shooting_frequency, function() can_shoot = true end)
  enemy:stop_movement()
  sol.audio.play_sound("bomb")
  sprite:set_animation("shooting", function() sprite:set_animation("walking") enemy:check_hero() end)
	local x, y, layer = enemy:get_position()
--  local bomb = map:create_bomb({x = x, y = y, layer = layer})
  local bomb = map:create_enemy({name = "bomb",x = x, y = y, layer = layer, direction = 0, breed = "misc/thyme_bomb"})
  local angle = enemy:get_angle(hero)
  local bombm = sol.movement.create("straight")
  bombm:set_smooth(false)
  bombm:set_speed(70)
  bombm:set_angle(angle)
  bombm:set_max_distance(30)
  bombm:start(bomb)

end
--]]

--Backup Behavior
--To use this, the animation "teleport_charge" needs to be set to looping.
--
local enemy = ...


local behavior = require("enemies/lib/archer_teleport")
enemy.immobilize_immunity = true
enemy.height = 16

local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  hurt_style = "boss",
  life = 85,
  damage = 8,
  normal_speed = 15,
  faster_speed = 50,
  teleport_charge_length = 500,
  teleport_threshold = 150,
  teleport_frequency = 7000,
  detection_distance = 300,
  attack_frequency = 2500,
  attack_sound = "bomb",
  projectile_breed = "misc/thyme_bomb",
  explode_when_teleporting = true,
  explosion_consequence = "protected",
  sword_while_teleporting_consequence = "protected"
}

behavior:create(enemy, properties)

enemy:set_dying_sprite_id("enemies/enemy_killed_ko")
--]]