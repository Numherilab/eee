local behavior = {}

local normal_functions = require("enemies/lib/normal_functions")

function behavior:create(enemy, properties)

  local game = enemy:get_game()
  local map = enemy:get_map()
  local hero = map:get_hero()
  local going_hero = false
  local can_attack = true
  local attacking = false

  --initialize universal enemy stuff:
  normal_functions:initialize(enemy, properties)
  --this is pretty notmal too, but needs check_hero()
  function enemy:on_obstacle_reached(movement)
    if not going_hero then
      self:go_random()
      self:check_hero()
    end
  end


  --RESTART
  function enemy:on_restarted()
    self:get_sprite():set_animation("walking")
    going_hero = false
    self:go_random()
    self:check_hero()
  end


  --Check hero
  function enemy:check_hero()
    if not attacking then
      local near_hero = self:is_near_hero()
      if near_hero and not going_hero then
        going_hero = true
        self:go_hero()
      elseif not near_hero and going_hero then
        going_hero = false
        self:go_random()
      end
      --and also decide if we should attack or something
      if going_hero then self:check_to_attack() end
      sol.timer.start(self, 150, function()
        self:check_hero()
      end)
    end
  end


  --Check to Attack
  function enemy:check_to_attack()
    --check if hero is aligned, if necessary
    local aligned = true
    if properties.must_be_aligned_to_attack then
      if not ((math.abs(hero_x - x) < 16 or math.abs(hero_y - y) < 16)) then aligned = false end
    end
    if aligned and can_attack then
      self:attack()
      can_attack = false
      sol.timer.start(map, properties.attack_frequency, function() can_attack = true end)        
    end
  end


  --Attack!
  function enemy:attack()
    attacking = true
    enemy:stop_movement()
    going_hero = false
    enemy:get_sprite():set_animation("shooting")
    sol.timer.start(map, properties.wind_up_time, function()
      enemy:create_projectile()
    end)
  end

  function enemy:create_projectile()
    --get direction and position
    local direction = self:get_sprite():get_direction()
    local x, y, layer = self:get_position()
    local dx = {[0] = 4, [1] = 0, [2] = -4, [3] = 0}
    local dy = {[0] = 0, [1] = -4, [2] = 0, [3] = 4}
    dx, dy = dx[direction], dy[direction]
    --create projectile
    local projectile = enemy:create_enemy({
      x = dx, y = dy, layer = layer, direction = direction,
      breed = properties.projectile_breed
    })
    --Fire!
    if properties.projectile_angle == "any" then
      projectile:go(enemy:get_angle(hero))
    else
      projectile:go(direction)
    end
    sol.audio.play_sound"shoot_magic"
    --initialize projectile properties
    if properties.projectile_damage then
      projectile:set_damage(properties.projectile_damage)
    end
    if properties.projectile_split_children then
      projectile:set_num_children(properties.projectile_split_children)
    end
    if properties.projectile_num_bounces then
      projectile:set_max_bounces(properties.projectile_num_bounces)
    end

    attacking = false
    going_hero = false
    enemy:go_random()
    enemy:check_hero()
  end


end

return behavior