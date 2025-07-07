-- 3 fireballs shot by enemies like Zora and that go toward the hero.
-- They can be hit with the sword, this changes their direction.

--Zora fire is the exact same, but more powerful. This one is intended for enemies in Yarrowmouth/Ballast Harbor, or weak fireballs in Oakhaven. Zora fire should be standard for decent attacks Oakhaven and later.

local enemy = ...
enemy.immobilize_immunity = true
enemy.lighting_effect = 1

local sprites = {}

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(3)
  enemy:set_size(8, 8)
  enemy:set_origin(4, 4)
  enemy:set_obstacle_behavior("flying")
  enemy:set_can_hurt_hero_running(true)
  enemy:set_invincible()
  enemy:set_dying_sprite_id("enemies/enemy_killed_projectile")
  enemy:set_attack_consequence("sword", "custom")
  enemy:set_attack_consequence("arrow", "ignored")

  sprites[1] = enemy:create_sprite("enemies/" .. enemy:get_breed())
  -- Sprites 2 and 3 do not belong to the enemy to avoid testing collisions with them.
  sprites[2] = sol.sprite.create("enemies/" .. enemy:get_breed())
  sprites[3] = sol.sprite.create("enemies/" .. enemy:get_breed())
end

function enemy:go(direction)
  local movement = sol.movement.create("straight")
  movement:set_speed(150)
  movement:set_angle(direction)
  movement:set_smooth(false)

  function movement:on_obstacle_reached()
    enemy:remove()
  end

  -- Compute the coordinate offset of follower sprites.
  local x = math.cos(direction) * 10
  local y = -math.sin(direction) * 10
  sprites[1]:set_xy(2 * x, 2 * y)
  sprites[2]:set_xy(x, y)

  sprites[1]:set_animation("walking")
  sprites[2]:set_animation("following_1")
  sprites[3]:set_animation("following_2")

  movement:start(enemy)
end

function enemy:on_restarted()

  local hero = enemy:get_map():get_hero()
  local angle = enemy:get_angle(hero:get_center_position())
--  enemy:go(direction)
end

-- Destroy the fireball when the hero is touched.
enemy:register_event("on_attacking_hero", function(enemy, hero, enemy_sprite)

  hero:start_hurt(enemy, enemy_sprite, enemy:get_damage())
  enemy:remove()
end)

-- Change the direction of the movement when hit with the sword.
function enemy:on_custom_attack_received(attack, sprite)

  if attack == "sword" and sprite == sprites[1] then
    local hero = enemy:get_map():get_hero()
    local movement = enemy:get_movement()
    if movement == nil then
      return
    end

    local old_angle = movement:get_angle()
    local angle
    local hero_direction = hero:get_direction()
    if hero_direction == 0 or hero_direction == 2 then
      angle = math.pi - old_angle
    else
      angle = 2 * math.pi - old_angle
    end

    enemy:go(angle)
    sol.audio.play_sound("enemy_hurt")

    -- The trailing fireballs are now on the hero: don't attack temporarily
    enemy:set_can_attack(false)
    sol.timer.start(enemy, 500, function()
      enemy:set_can_attack(true)
    end)
  end
end

function enemy:on_pre_draw()

  local map = enemy:get_map()
  local x, y = enemy:get_position()
  map:draw_visual(sprites[2], x, y)
  map:draw_visual(sprites[3], x, y)
end