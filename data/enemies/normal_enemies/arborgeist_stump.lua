local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement
local detection_distance = 120
local can_attack = false
enemy.immobilize_immunity = true
enemy.weak_to_fire = true
enemy.height = 24

-- Event called when the enemy is initialized.
function enemy:on_created()
    enemy:set_life(60)
    enemy:set_damage(12)
    sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
    enemy:set_hurt_style("boss")
    enemy:set_pushed_back_when_hurt(false)
    enemy:set_push_hero_on_sword(false)
    self:set_size(32, 24)
    self:set_origin(16, 21)
end

-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.
function enemy:on_restarted()
  can_attack = true
  enemy:check_hero()
end


function enemy:check_hero()
  local _, _, layer = enemy:get_position()
  local _, _, hero_layer = hero:get_position()
  local near_hero = layer == hero_layer and enemy:get_distance(hero) < detection_distance and enemy:is_in_same_region(hero)

  if near_hero and can_attack then
    enemy:attack()
    can_attack = false
  end

  sol.timer.start(self, 100, function() self:check_hero() end)
end

function enemy:attack()
    local hero = map:get_hero()
    local herox, heroy, herol = hero:get_position()
    map:create_enemy({
      name = vine_enemy, layer = herol, x = herox, y = heroy, direction = 0, breed = "misc/root_small", 
    })
    sol.timer.start(enemy, 1500, function() can_attack = true end)
    return true
end


function enemy:react_to_fire()
  enemy:propagate_fire()
end

