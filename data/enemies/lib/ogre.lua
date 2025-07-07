local behavior = {}

local normal_functions = require("enemies/lib/normal_functions")

function behavior:create(enemy, properties)

  local game = enemy:get_game()
  local map = enemy:get_map()
  local hero = map:get_hero()
  local going_hero = false
  local can_attack = true
  local attacking = false

  function enemy:on_started()
    enemy:set_size(24,24)
  end

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
    if aligned and can_attack and self:get_distance(hero) <= properties.melee_distance then
      self:attack()
      can_attack = false
      sol.timer.start(map, properties.attack_frequency, function() can_attack = true end)        
    end
  end


  --Attack!
  function enemy:attack()
    local direction = self:get_sprite():get_direction()
    local x, y, layer = self:get_position()
    local dx = {[0] = -16, [1] = 0, [2] = 16, [3] = 0}
    local dy = {[0] = 0, [1] = -16, [2] = 0, [3] = 16}
    dx, dy = dx[direction], dy[direction]

    attacking = true
    enemy:stop_movement()
    going_hero = false
    enemy:set_pushed_back_when_hurt(false)
    enemy:get_sprite():set_animation("wind_up")
    enemy:set_attack_consequence("sword", "protected")
    sol.timer.start(map, properties.wind_up_time, function()
      sol.audio.play_sound"sword4"
      enemy:get_sprite():set_animation("attack", function()
        enemy:set_attack_consequence("sword", "protected")
        enemy:set_attack_consequence("sword", 1)
        enemy:get_sprite():set_animation("walking")
        enemy:go_random()
        enemy:check_hero()
      end)
      enemy:set_pushed_back_when_hurt(true)

      if properties.attack_sprites then
        for i=1, #properties.attack_sprites do
          local attack_sprite = enemy:create_sprite(properties.attack_sprites[i])
          attack_sprite:set_direction(direction)
          enemy:set_invincible_sprite(attack_sprite)
          enemy:set_attack_consequence_sprite(attack_sprite, "sword", "custom")
        end
      end

      attacking = false
    end)
  end


  --if you deflect the attack
  function enemy:on_custom_attack_received(attack, sprite)
    if attack == "sword" and sprite == attack_sprite then
      sol.audio.play_sound("sword_tapping")
--      being_pushed = true
      local x, y = enemy:get_position()
      local angle = hero:get_angle(enemy)
      local movement = sol.movement.create("straight")
      movement:set_speed(128)
      movement:set_angle(angle)
      movement:set_max_distance(26)
      movement:set_smooth(true)
      movement:start(enemy)
    end
  end


end

return behavior