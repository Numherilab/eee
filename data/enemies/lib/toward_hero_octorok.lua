local behavior = {}

function behavior:create(enemy, properties)

  local children = {}

  local can_attack = true

  local going_hero = false

  -- Set default properties.
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
  if properties.size_x == nil then
    properties.size_x = 16
  end
  if properties.size_y == nil then
    properties.size_y = 16
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
    properties.detection_distance = 120
  end
  if properties.obstacle_behavior == nil then
    properties.obstacle_behavior = "normal"
  end
--this one can be either "straight", "diagonal", or "any"
  if properties.projectile_angle == nil then
    properties.projectile_angle = "straight"
  end
  if properties.projectile_breed == nil then
    properties.projectile_breed = "misc/octorok_stone"
  end
  if properties.shooting_frequency == nil then
    properties.shooting_frequency = 1500
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
  if properties.must_be_aligned_to_shoot == nil then
    properties.must_be_aligned_to_shoot = true
  end


  function enemy:on_created()

    self:set_life(properties.life)
    self:set_damage(properties.damage)
    self:create_sprite(properties.sprite)
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
    local layer = self:get_layer()
    local hero_layer = hero:get_layer()
    local near_hero =
        (layer == hero_layer or enemy:has_layer_independent_collisions()) and
        self:get_distance(hero) < properties.detection_distance and
        self:is_in_same_region(hero)

    if near_hero and not going_hero then
      self:go_hero()
    elseif not near_hero and going_hero then
      self:go_random()
    end

    if near_hero then enemy:check_to_attack() end

    sol.timer.stop_all(self)
    sol.timer.start(self, 200, function() self:check_hero() end)
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
    if can_attack and aligned and (enemy:get_distance(hero) <= (properties.detection_distance or 100)) then
      enemy:shoot()
      can_attack = false
      sol.timer.start(map, properties.attack_frequency or 4000, function() can_attack = true end)
    end
  end


  function enemy:shoot()
    local map = enemy:get_map()
    local hero = map:get_hero()

    local sprite = enemy:get_sprite()
    local x, y, layer = enemy:get_position()
    local dir_sprite = sprite:get_direction()
    local direction

    if sprite:has_animation"wind_up" then
      sprite:set_animation"wind_up"
    else
      sprite:set_animation("shooting")
    end

    if properties.projectile_angle == "straight" then
      direction = sprite:get_direction()
    elseif properties.projectile_angle == "diagonal" then
      direction = self:get_direction8_to(hero)
    elseif properties.projectile_angle == "any" then
      direction = self:get_angle(hero)
    end

    -- Where to create the projectile.
    local dxy = {
    {  8,  -4 },
    {  0, -13 },
    { -8,  -4 },
    {  0,   0 },
    }

    enemy:stop_movement()
    sol.timer.start(map, 500, function()
      sprite:set_animation("shooting")
      sol.timer.start(map, sprite:get_num_frames() * sprite:get_frame_delay(), function()
        sol.audio.play_sound("shoot")
        local stone = enemy:create_enemy({
          breed = properties.projectile_breed,
          x = dxy[dir_sprite + 1][1],
          y = dxy[dir_sprite + 1][2],
        })
        children[#children + 1] = stone
        stone:go(direction)
        sprite:set_animation("walking")
        self:restart()
      end) --end animation callback function
    end)
  end


end

return behavior
