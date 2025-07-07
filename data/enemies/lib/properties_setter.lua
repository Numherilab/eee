local properties_setter = {}

function properties_setter:set_properties(enemy, properties)

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
    properties.detection_distance = 180
  end

  if properties.obstacle_behavior == nil then
    properties.obstacle_behavior = "normal"
  end

  if properties.projectile_breed == nil then
    properties.projectile_breed = "misc/octorok_stone"
  end

  if properties.attack_frequency == nil then
    properties.attack_frequency = 3500
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

  if properties.must_be_aligned_to_attack == nil then
    properties.must_be_aligned_to_attack = false
  end

  if properties.melee_distance == nil then
    properties.melee_distance = 32
  end

  if properties.wind_up_time == nil then
    properties.wind_up_time = 400
  end

  if properties.melee_sound == nil then
    properties.melee_sound = "sword3"
  end

  if properties.vulnerable_in_windup == nil then
    properties.vulnerable_in_windup = false
  end



  enemy:register_event("on_created", function()
    enemy:set_life(properties.life)
    enemy:set_damage(properties.damage)
    enemy:create_sprite(properties.sprite)
    enemy:set_hurt_style(properties.hurt_style)
    if properties.dying_sprite then enemy:set_dying_sprite_id(properties.dying_sprite) end
    enemy:set_pushed_back_when_hurt(properties.pushed_when_hurt)
    enemy:set_push_hero_on_sword(properties.push_hero_on_sword)
    enemy:set_obstacle_behavior(properties.obstacle_behavior)
    enemy:set_size(properties.size_x, properties.size_y)
    enemy:set_origin(properties.size_x / 2, properties.size_y - 3)
    enemy:set_attack_consequence("explosion", properties.explosion_consequence)
    enemy:set_attack_consequence("fire", properties.fire_consequence)
    enemy:set_attack_consequence("sword", properties.sword_consequence)
    enemy:set_attack_consequence("arrow", properties.arrow_consequence)
    if properties.shield_sprite then
      sword_sprite = enemy:create_sprite(properties.shield_sprite)
      enemy:set_invincible_sprite(sword_sprite)
      enemy:set_attack_consequence_sprite(sword_sprite, "sword", "protected")
    end
  end)

end

return properties_setter