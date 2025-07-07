local behavior = {}

-- Behavior of an enemy that goes towards the
-- the hero if he sees him, and randomly walks otherwise.
-- The enemy has only one sprite.

-- Example of use from an enemy script:

-- local enemy = ...
-- local behavior = require("enemies/lib/towards_hero")
-- local properties = {
--   sprite = "enemies/globul",
--   life = 1,
--   damage = 2,
--   normal_speed = 32,
--   faster_speed = 32,
--   hurt_style = "normal",
--   push_hero_on_sword = false,
--   pushed_when_hurt = true,
--   ignore_obstacles = false,
--   obstacle_behavior = "flying",
--   detection_distance = 100,
--   movement_create = function()
--     local m = sol.movement.create("random_path")
--     return m
--   end
-- }
-- behavior:create(enemy, properties)

-- The properties parameter is a table.
-- All its values are optional except the sprite.

function behavior:create(enemy, properties)

  local going_hero = false
  local can_attack = true

  -- Set default properties.
  if properties.size_x == nil then
    properties.size_x = 16
  end
  if properties.size_y == nil then
    properties.size_y = 16
  end
  if properties.life == nil then
    properties.life = 2
  end
  if properties.damage == nil then
    properties.damage = 2
  end
  if properties.normal_speed == nil then
    properties.normal_speed = 32
  end
  if properties.faster_speed == nil then
    properties.faster_speed = 48
  end
  if properties.hurt_style == nil then
    properties.hurt_style = "normal"
  end
  if properties.pushed_when_hurt == nil then
    properties.pushed_when_hurt = true
  end
  if properties.push_hero_on_sword == nil then
    properties.push_hero_on_sword = false
  end
  if properties.ignore_obstacles == nil then
    properties.ignore_obstacles = false
  end
  if properties.detection_distance == nil then
    properties.detection_distance = 80
  end
  if properties.obstacle_behavior == nil then
    properties.obstacle_behavior = "normal"
  end
  if properties.explosion_consequence == nil then
    properties.explosion_consequence = 1
  end
  if properties.fire_consequence == nil then
    properties.fire_consequence = 1
  end
  if properties.sword_consequence == nil then
    properties.sword_consequence = 1
  end
  if properties.arrow_consequence == nil then
    properties.arrow_consequence = 1
  end
  if properties.movement_create == nil then
    properties.movement_create = function()
      local m = sol.movement.create("random_path")
      return m
    end
  end

  function enemy:on_created()

    self:set_life(properties.life)
    self:set_damage(properties.damage)
    self.sprite = self:create_sprite(properties.sprite)
    self:set_hurt_style(properties.hurt_style)
    self:set_pushed_back_when_hurt(properties.pushed_when_hurt)
    self:set_push_hero_on_sword(properties.push_hero_on_sword)
    self:set_obstacle_behavior(properties.obstacle_behavior)
    self:set_size(properties.size_x, properties.size_y)
    self:set_origin(properties.size_x / 2, properties.size_y - 3)
    self:set_attack_consequence("explosion", properties.explosion_consequence)
    self:set_attack_consequence("fire", properties.fire_consequence)
    self:set_attack_consequence("sword", properties.sword_consequence)
    self:set_attack_consequence("arrow", properties.arrow_consequence)
    if properties.dying_sprite then self:set_dying_sprite_id(properties.dying_sprite) end
  end


  function enemy:on_movement_changed(movement)
    local direction4 = movement:get_direction4()
    local sprite = self:get_sprite()
    sprite:set_direction(direction4)
    local ground = self:get_ground_below()
    if not self.grass_sprite and ground == "grass" then
      self.grass_sprite = self:create_sprite("hero/ground1")
    elseif self.grass_sprite and ground ~= "grass" then
      self:remove_sprite(self.grass_sprite)
      self.grass_sprite = nil
    end
  end

  function enemy:on_obstacle_reached(movement)

    if not going_hero then
      self:go_random()
      self:check_hero()
    end
  end

  function enemy:on_restarted()
    self:go_random()
    self:check_hero()
  end

  function enemy:check_hero()

    local hero = self:get_map():get_entity("hero")
    local _, _, layer = self:get_position()
    local _, _, hero_layer = hero:get_position()
    local near_hero =
        (layer == hero_layer or enemy:has_layer_independent_collisions()) and
        self:get_distance(hero) < properties.detection_distance
        self:is_in_same_region(hero)

    if near_hero and not going_hero then
      self:go_hero()
    elseif not near_hero and going_hero then
      self:go_random()
    end

    enemy:check_to_attack()

    sol.timer.stop_all(self)
    sol.timer.start(self, 100, function() self:check_hero() end)
  end

  function enemy:go_random()
    going_hero = false
    local m = properties.movement_create()
    if m == nil then
      -- No movement.
      self:get_sprite():set_animation("stopped")
      m = self:get_movement()
      if m ~= nil then
        -- Stop the previous movement.
        m:stop()
      end
    else
      m:set_speed(properties.normal_speed)
      m:set_ignore_obstacles(properties.ignore_obstacles)
      m:start(self)
    end
  end

  function enemy:go_hero()
    going_hero = true
    local m = sol.movement.create("target")
    m:set_speed(properties.faster_speed)
    m:set_ignore_obstacles(properties.ignore_obstacles)
    m:start(self)
    self:get_sprite():set_animation("walking")
  end


  function enemy:check_to_attack()
    local map = enemy:get_map()
    local hero =  map:get_hero()
    local x, y, z = enemy:get_position()
    local hx, hy, hz = hero:get_position()
    local aligned = (properties.must_be_aligned_to_attack and math.abs(x - hx) <= 16 and math.abs(y - hy) <= 16)
      or true
    if can_attack and aligned and (enemy:get_distance(hero) <= (properties.melee_distance or 32)) then
      enemy:attack()
      can_attack = false
      sol.timer.start(map, properties.attack_frequency or 4000, function() can_attack = true end)
    end
  end


	function enemy:attack()
    enemy:stop_movement()
    enemy:get_sprite():set_animation("wind_up")
    if not properties.vulnerable_in_windup then
      enemy:set_attack_consequence("sword", "protected")
    end
    sol.timer.start(enemy:get_map(), properties.wind_up_time, function()
      if enemy:get_life() > 0 and properties.melee_sound then sol.audio.play_sound(properties.melee_sound) end
      enemy:get_sprite():set_animation("attack", function()

        enemy:set_attack_consequence("sword", properties.sword_consequence)
        enemy:restart()
      end)
    end)
  end


end

return behavior