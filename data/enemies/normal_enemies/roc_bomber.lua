local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement
local can_attack = true
local going_hero = false
local detection_distance = 180
local attack_distance = 32

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:set_can_attack(false)
  enemy:set_obstacle_behavior("flying")
  enemy:set_invincible()
  enemy.immobilize_immunity = true
end


function enemy:on_restarted()
  going_hero = false
  enemy:go_random()
  enemy:check_hero()
end

function enemy:on_movement_changed(mov)
  local dir = mov:get_direction4()
  sprite:set_direction(dir)
end


function enemy:check_hero()
  local hx, hy, hz = hero:get_position()
  local near_hero = enemy:get_distance(hero) < detection_distance and enemy:is_in_same_region(hero)
  if near_hero and not going_hero then
    going_hero = true
    enemy:go_hero()
  end

  local near_attack = enemy:get_distance(hero) < attack_distance and enemy:is_in_same_region(hero)
  if near_attack and can_attack
  then
    enemy:attack()
    can_attack = false
  end
  sol.timer.start(self, 100, function() self:check_hero() end)
end


function enemy:go_random()
  movement = sol.movement.create("random_path")
  movement:set_ignore_obstacles(true)
  movement:set_speed(36)
  movement:start(enemy)
end


function enemy:go_hero()
  movement = sol.movement.create("target")
  movement:set_ignore_obstacles(true)
  movement:set_speed(100)
  movement:start(enemy)
end


function enemy:attack()
  sprite:set_animation("flapping")
  sol.audio.play_sound"bird/raven_17"
  sol.audio.play_sound"bird/raven_19"
  sol.timer.start(enemy, 900, function()
    sprite:set_animation"walking"
    local x,y,l = hero:get_position()
    map:create_enemy{
      x=x,y=y,layer=map:get_max_layer(),direction=0,breed="misc/falling_egg"
    }
    enemy:go_random()
    sol.timer.start(enemy,3500, function()
      can_attack = true
      enemy:restart()
    end)
  end)
end

function enemy:hit_by_lightning()
  enemy:remove_life(5)
end

