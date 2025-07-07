local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement
local going_hero
local detection_distance = 150
local slower_speed = 15
local faster_speed = 30
enemy.height = 16


function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(3)
  enemy:set_consequence_for_all_attacks("protected")
  enemy:set_attack_consequence("thrown_item", 0)
end


function enemy:on_restarted()
  enemy:get_sprite():set_animation("walking")
  going_hero = false
  enemy:go_random()
  sol.timer.start(self, 200, function() enemy:check_hero() return true end)
end

function enemy:check_hero()
    local near_hero = enemy:is_near_hero()
    
    if near_hero and not going_hero then
      going_hero = true
      enemy:go_hero()
    elseif not near_hero and going_hero then
      going_hero = false
      enemy:go_random()
    end
end

function enemy:is_near_hero()
  local layer = enemy:get_layer()
  local hero_layer = hero:get_layer()
  local dist_hero = enemy:get_distance(hero)
  local near_hero = (layer == hero_layer or enemy:has_layer_independent_collisions())
    and dist_hero <= detection_distance and enemy:is_in_same_region(hero)
  return near_hero
end

function enemy:go_random()
  going_hero = false
  local m = sol.movement.create("random_path")
    m:set_speed(slower_speed)
    m:start(enemy)
end

function enemy:go_hero()
  going_hero = true
  local m = sol.movement.create("target")
  m:set_speed(faster_speed)
  m:start(enemy)
  enemy:get_sprite():set_animation("walking")
end


--Here's where the enemy breaks into smaller enemies
function enemy:hit_by_toss_ball()
  enemy:remove_life(5)
  enemy:hurt(1)
end

function enemy:on_dead()
  for i = 1, 3 do
    local gravel_guy = enemy:create_enemy({name = "boulder_bro_spawn", breed = "normal_enemies/gravel_guy"})
  end
end