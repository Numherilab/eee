--An enemy archetype that has multiple attacks and behaviors available to it.

--properties.wind_up_time is a general length for enemies to telegraph that they're about to attack
--properties.movement_circle_hero will give the enemy a circling movement when near the hero,
  --this property requires movement_circle_hero_radius and movement_circle_hero_speed to be set as well.

--each attack has it's own <attack>_wind_up_time that will override this.

--Which attacks the enemy can do are set in the enemy's properties. Values are:
--has_melee_attack, melee_distance, melee_attack_cooldown, melee_attack_sound("sound effect"), attack_sprites{} (a table of sprites)
    --optional, melee_attack_wind_up_time (this is an optional property for each attack, assume it's true for all)
--has_teleport, teleport_distance, teleport_cooldown,invincible_while_charging_teleport, teleport_length (how far enemy travels)
  --time_phased_out, stop_movement_while_teleporting
  --optional: teleport_wind_up_time (assume this for all attacks, again)
--has_dash_attack, dash_attack_distance (hero distance threshold), dash_attack_cooldown,
    --dash_attack_direction ("target_hero" or "straight"), dash_attack_length (how far the enemy will dash before stopping)
    --dash_attack_speed, dash_attack_wind_up, dash_attack_sound, invincible_while_dashing(bool)
    --TODO allow to set a function as a property for a callback when the dash is over or a collision with an obstacle happens
--has_ranged_attack, ranged_attack_distance, ranged_attack_cooldown, ranged_attack_sound,
    --projectile_breed, projectile_angle ("any", or "straight")
    --optional properties for ranged attack are projectile_damage, projectile_split_children, and projectile_num_bounces
    --(make sure the projectile breed you set can take these parameters to avoid errors)
    --(the projectile breed also requires an enemy:go(angle) function which is called right after it's created)
--has_summon_attack, summon_attack_distance, summon_attack_cooldown, summoning_sound,
    --summon_breed, summon_group_size, summon_group_delay, protected_while_summoning,
    --summon group size refers to, for instance, if the enemy summons 3 bolts of lightning at a time.
    --summon group delay refers to time between each of those 3 bolts of lightning. After that, cooldown will start
--has_orbit_attack, orbit_attack_distance, orbit_attack_cooldown, orbit_attack_sound, orbit_attack_num_projectiles
      --orbit_attack_charge_time, orbit_attack_shoot_delay, orbit_attack_projectile_delay, orbit_attack_projectile_breed,
      --orbit_attack_radius, orbit_attack_launch_sound, orbit_attack_stop_while_charging
      --use_projectile_go_method, if true this will call projectile:go(angle to hero) and allow bouncing, so make sure
      --your projectile has a go(angle) method or else errors.
--has_radial_attack, radial_attack_distance, radial_attack_cooldown, radial_attack_sound, radial_attack_num_projectiles,
      --radial_attack_charge_time, radial_attack_shoot_delay, radial_attack_projectile_breed,
--has_flail_attack, flail_attack_distance, flail_attack_cooldown,
--optional: flail_wind_up_time, flail_sprite, flail_radius flail_max_rotations, flail_max_distance, flail_speed
--has_boomerang_attack, boomerang_attack_distance, boomerang_attack_cooldown,
--optional: boomerang_wind_up_time, boomerang_sprite, boomerang_max_distance, boomerang_speed

--For a custom attack (TODO - debug custom attack, which sometimes results in the enemy stopping the check_hero() loop)
      --properties.has_custom_attack - For this script to check requirements, and if met, start the attack
      --properties.custom_attack_cooldown - cooldown in ms for custom attack
      --properties.custom_attack_requirements - function that returns a boolean to check if custom attack can be done
        --this should check for distance from hero, alignment, etc.
      --properties.custom_attack - function that determines what happens.
        --This function must take a callback function as an argument for what to do when attack is finished.


--Required Animations:
--walking, hurt, immobilized, shaking, wind_up (must loop)

--Certain animations are required for certain attacks:
--For a melee attack:"attack" (must not loop)
  --optional: melee_attack_wind_up
--For teleporting away: "phasing_out (must not loop)", "phasing_in (must not loop)", "teleporting"
  --optional: teleport_wind_up
--For a dash attack:
  --optional: "dashing", "dash_attack_wind_up"
-- For a summon attack
  --optional:summoning_wind_up
--For a ranged attack: "shooting" (must not loop)
  --optional: shooting_wind_up
--For an orbit attack
  --optional: "orbit_attack_wind_up"
--For flail attack
--optional sprite:"flail_wind_up"
--For boomerang attack:
--optional sprite: "boomerang_wind_up"

--TODO - allow to set a function as a property that is called for enemy:go_hero()
    --to allow more complex movements, such as circling the hero.

--Notes:
--If enemy has both summoning and ranged attack, both attacks are cooled down, and the hero is
--in range of both attacks, summoning has a higher priority. Really, this is and issue for any
--two or more attacks with the same range and cooldown status. The hierarchy of priority is:
--Melee > Teleport > Dash Attack > Summon Attack > Ranged Attack

--properties.must_be_aligned_to_attack is true for both shooting and melee
--TODO - break alignment requirement into separate componenets different attacks

--Local value attacking is used for all attacks to keep the enemy from trying to do an attack while already executing one.

--Cooldowns are set to map timers so as not to be reset when the enemy is damaged.

local behavior = {}

local normal_functions = require("enemies/lib/normal_functions")


function behavior:create(enemy, properties)

  local game = enemy:get_game()
  local map = enemy:get_map()
  local hero = map:get_hero()
  local going_hero = false
  local can_null_test_attack = true
  local can_custom_attack = true
  local can_melee = true
  local can_teleport = true
  local can_dash_attack = true
  local can_summon = true
  local can_shoot = true
  local can_orbit_attack = true
  local can_radial_attack = true
  local can_flail_attack = true
  local can_boomerang_attack = true
  local can_airstrike_attack = true
  local can_surround_attack = true
  local attacking = false
  local currently_dashing = false
  local currently_teleporting = false
  if properties.has_shield then
    enemy.shield_down = false
  end

  --initialize universal enemy stuff:
  normal_functions:initialize(enemy, properties)


  --Deal with hitting obstacle in movement
  function enemy:on_obstacle_reached(movement)
    if not going_hero and attacking == false then
      self:go_random()
      self:check_hero()
    end
  end


  --RESTART
  function enemy:on_restarted()

    if properties.has_shield and enemy.shield_down == true then
      for sprite_name, sprite in entity:get_sprites() do
        enemy:remove_sprite(sprite)
      end
      enemy:create_sprite("enemies/" .. enemy:get_breed() .. "_vulnerable")
      enemy:set_default_attack_consequences()
    elseif properties.has_shield then
      enemy:set_consequence_for_all_attacks("protected")
    end

    if currently_dashing then attacking = false currently_dashing = false end
    self:get_sprite():set_animation("walking")
    going_hero = false
    self:go_random()
    sol.timer.start(self, 10, function() enemy:check_hero() return 100 end)
  end


  --Check hero
  function enemy:check_hero()
    if not attacking then
      local near_hero = self:is_near_hero()
      enemy:check_to_break_circle()

      if near_hero and not going_hero then
        going_hero = true
        self:go_hero()
      elseif not near_hero and going_hero then
        going_hero = false
        self:go_random()
      end
      --and also decide if we should attack or something
      if going_hero then self:check_to_attack() end
    end
  end


  --Check to Attack
  function enemy:check_to_attack()
    --check if hero is aligned, if necessary
    local aligned = true
    local dist_hero = self:get_distance(hero)
    local hero_x, hero_y, hero_layer = hero:get_position()
    local x, y, layer = self:get_position()
    if properties.must_be_aligned_to_attack then
      if not ((math.abs(hero_x - x) < 16 or math.abs(hero_y - y) < 16)) then aligned = false end
    end

    --choose what attack to do:
    -- if properties.has_custom_attack and can_custom_attack and properties.custom_attack_requirements then
    --   attacking = true
    --   going_hero = false
    --   can_custom_attack = false
    --   local f = properties.custom_attack
    --   f(function() enemy:wrap_up_attack() enemy:go_random() enemy:check_hero() end)
    --   sol.timer.start(map, properties.custom_attack_cooldown, function() can_custom_attack = true end)

    if properties.has_null_test_attack then
      attacking = true
      going_hero = false
      self:null_test_attack()
      can_null_test_attack = false
      sol.timer.start(map, 1000, function() can_null_test_attack = true end)

    elseif properties.has_melee_attack and aligned and can_melee and dist_hero <= properties.melee_distance then
      attacking = true
      going_hero = false
      self:melee_attack()
      can_melee = false
      sol.timer.start(map, properties.melee_attack_cooldown + math.random(800), function() can_melee = true end)

    elseif properties.has_teleport and can_teleport and dist_hero <= properties.teleport_distance then
      attacking = true
      going_hero = false
      self:teleport()
      can_teleport = false
      sol.timer.start(map, properties.teleport_cooldown + math.random(1000), function() can_teleport = true end)

    elseif properties.has_summon_attack and can_summon and dist_hero <= properties.summon_attack_distance then
      attacking = true
      going_hero = false
      self:summon()
      can_summon = false
      sol.timer.start(map, properties.summon_attack_cooldown + math.random(1000), function() can_summon = true end)

    elseif properties.has_dash_attack and can_dash_attack and dist_hero <= properties.dash_attack_distance then
      attacking = true
      going_hero = false
      self:dash_attack()
      can_dash_attack = false
      sol.timer.start(map, properties.dash_attack_cooldown + math.random(1000), function() can_dash_attack = true end)

    elseif properties.has_airstrike_attack and can_airstrike_attack and dist_hero <= properties.airstrike_attack_distance then
      attacking = true
      going_hero = false
      self:airstrike()
      can_airstrike_attack = false
      sol.timer.start(map, properties.airstrike_attack_cooldown + math.random(1000), function() can_airstrike_attack = true end)

    elseif properties.has_ranged_attack and aligned and can_shoot and dist_hero <= properties.ranged_attack_distance then
      attacking = true
      going_hero = false
      self:ranged_attack()
      can_shoot = false
      sol.timer.start(map, properties.ranged_attack_cooldown + math.random(500), function() can_shoot = true end)

    elseif properties.has_orbit_attack and can_orbit_attack and dist_hero <= properties.orbit_attack_distance then
      attacking = true
      going_hero = false
      self:orbit_attack()
      can_orbit_attack = false
      sol.timer.start(map, properties.orbit_attack_cooldown + math.random(1000), function() can_orbit_attack = true end)

    elseif properties.has_radial_attack and can_radial_attack and dist_hero <= (properties.radial_attack_distance or 100) then
      local rounds = properties.radial_attack_rounds or 1
      attacking = true
      going_hero = false
      for i = 1, rounds do
        local round_delay = (properties.radial_attack_round_delay or 1500)
        sol.timer.start(map, round_delay * i - round_delay, function()
          self:radial_attack()
        end)
      end
      can_radial_attack = false
      sol.timer.start(map, properties.radial_attack_cooldown + math.random(800), function() can_radial_attack = true end)

    elseif properties.has_flail_attack and can_flail_attack and dist_hero <= properties.flail_attack_distance then
      attacking = true
      going_hero = false
      self:flail_attack()
      can_flail_attack = false
      sol.timer.start(map, properties.flail_attack_cooldown + math.random(500), function() can_flail_attack = true end)

    elseif properties.has_boomerang_attack and can_boomerang_attack and dist_hero <= properties.boomerang_attack_distance then
      attacking = true
      going_hero = false
      self:boomerang_attack()
      can_boomerang_attack = false
      sol.timer.start(map, properties.boomerang_attack_cooldown + math.random(500), function() can_boomerang_attack = true end)

    elseif properties.has_surround_attack and can_surround_attack and dist_hero <= properties.surround_attack_distance then
      attacking = true
      going_hero = false
      self:surround_attack()
      can_surround_attack = false
      sol.timer.start(map, properties.surround_attack_cooldown + math.random(800), function() can_surround_attack = true end)


    end

  end



  --this needs to be called after each attack:
  function enemy:wrap_up_attack()
    sol.timer.start(map, properties.time_between_attacks or 1300, function()
      attacking = false
      enemy:restart() ---_WOOOAH RISKY BUT MAYBE IT'LL BE OKAY?? Nothing should be scoped enemy anyway
    end)
  end


  --Melee Attack
  function enemy:melee_attack()
    local direction = self:get_direction4_to(hero)
    local x, y, layer = self:get_position()
    enemy:stop_movement()
    enemy:set_pushed_back_when_hurt(false)
    local wind_up_animation
    local sprite = enemy:get_sprite()
    sprite:set_animation("wind_up")
    if sprite:has_animation("melee_wind_up") then sprite:set_animation("melee_wind_up") end
    local dx = {[0]=-8, [1]=8, [2]=8, [3]=-8}
    local dy = {[0]=-0, [1]=8, [2]=0, [3]=-8}
    map:create_custom_entity{
      x=x+dx[sprite:get_direction()], y=y+dy[sprite:get_direction()], layer= layer, direction=0,height=16,width=16,
      model="ephemeral_effect", sprite="entities/enemy_attack_flash",
    }
    local telegraph_time = properties.wind_up_time
    if properties.melee_attack_wind_up_time then telegraph_time = properties.melee_attack_wind_up_time end
    sol.timer.start(map, telegraph_time, function()
      if enemy:get_life() <= 0 then return end --to avoid trying to play sprites when already dead
      local m = sol.movement.create("straight")
      m:set_angle(enemy:get_angle(hero))
      m:set_speed(130)
      m:set_max_distance(8)
      m:start(enemy)

      sol.audio.play_sound(properties.melee_attack_sound or "sword2")
      enemy:get_sprite():set_animation("attack", function()
        enemy:set_attack_consequence("sword", properties.sword_consequence)
        enemy:get_sprite():set_animation("walking")
        going_hero = false
        enemy:go_random()
        enemy:check_hero()
      end)
      enemy:set_pushed_back_when_hurt(true)

      if properties.attack_sprites then
        for i=1, #properties.attack_sprites do
          local attack_sprite = enemy:create_sprite(properties.attack_sprites[i])
          attack_sprite:set_direction(direction)
          enemy:set_invincible_sprite(attack_sprite)
          enemy:set_attack_consequence_sprite(attack_sprite, "sword", "protected")
          sol.timer.start(map, 1000, function()
            if enemy:exists() and attack_sprite then enemy:remove_sprite(attack_sprite) end
          end)
        end
      end
      enemy:wrap_up_attack()
    end)
  end



  --Teleport
  function enemy:teleport()
    if properties.stop_movement_while_teleporting then enemy:stop_movement() end
    local sprite = enemy:get_sprite()
    enemy:set_can_attack(false)
    enemy:set_invincible()
    sprite:set_animation("phasing_out")
    sol.audio.play_sound(properties.teleport_sound or "warp")
    sol.timer.start(map, 1000, function()
      currently_teleporting = true
      sprite:set_animation("teleporting")
      local m = sol.movement.create("straight")
      m:set_speed(100)
      m:set_smooth()
      m:set_max_distance(properties.teleport_length)
      m:set_angle(math.random(0, math.pi * 2))
      m:start(enemy)
      sol.timer.start(map, properties.time_phased_out, function()
        sol.audio.play_sound(properties.teleport_sound or "warp")
        sprite:set_animation("phasing_in", function()
          sprite:set_animation("walking")
        end)
        sol.timer.start(map, 1500, function()
          currently_teleporting = false
          enemy:set_default_attack_consequences()
          enemy:set_can_attack()
          enemy:wrap_up_attack()
          going_hero = false
          enemy:go_random()
          enemy:check_hero()
        end)
      end)
    end)

  end


  --Dash Attack
  function enemy:dash_attack()
    enemy:stop_movement() --stop moving while winding up
    local sprite = enemy:get_sprite()
    --set the general wind-up animation
    sprite:set_animation("wind_up")
    --actually, change it to a specific dash wind up if there is one
    if sprite:has_animation("dash_attack_wind_up") then sprite:set_animation("dash_attack_wind_up") end
    --set general telegraph time, or change it to dash attack telegraph telegraph time if applicable
    local telegraph_time = properties.wind_up_time
    if properties.dash_attack_wind_up_time then telegraph_time = properties.dash_attack_wind_up_time end
    --make some little dust clouds to communicate we're about to run
    local x, y, z = enemy:get_position()
    local making_dust = true
    sol.timer.start(map, 10, function()
      local dust = map:create_custom_entity{ x=x+math.random(-4,4), y=y+2, layer=z, direction=0,width=16,height=16,
        model="ephereral_effect", sprite="entities/dust_running"
      }
      dust:set_drawn_in_y_order(true)
      dust:get_sprite():set_animation("stopped", function() dust:remove() end)
      if making_dust then return 299 end
    end)
    --after the telegraph, dash at the hero!
    sol.timer.start(map, telegraph_time, function()
      making_dust = false
      if enemy:get_life() <= 0 then return end --to prevent the death animation of the enemy from rushing at you
      currently_dashing = true
      sprite:set_animation("walking")
      if sprite:has_animation("dashing") then sprite:set_animation("dashing") end
      local m = sol.movement.create("straight")
      if properties.dash_attack_direction == "target_hero" then
        m:set_angle(enemy:get_angle(hero))
      else
        m:set_angle(enemy:get_movement():get_direction4())
      end
      m:set_speed(properties.dash_attack_speed or 100)
      m:set_smooth(properties.dash_attack_smooth or false)
      sol.audio.play_sound(properties.dash_attack_sound or "gravel")
      if properties.invincible_while_dashing then enemy:set_invincible() end
      m:start(enemy)
      function m:on_finished()
        -- print("movement done"..n)n=n+1
        currently_dashing = false
        enemy:set_default_attack_consequences()
        attacking = false
        going_hero = false
        enemy:restart()
        -- enemy:go_random()
        -- enemy:check_hero()

      end
      function m:on_obstacle_reached()
--        print("obstacle reached! "..n)
        currently_dashing = false
        enemy:set_default_attack_consequences()
        attacking = false
        going_hero = false
        enemy:restart()
        -- enemy:go_random()
        -- enemy:check_hero()
      end
      -- sol.timer.start(map, 1000, function() enemy:wrap_up_attack() end) --just in case
    end)
  end



  --Summon Attack
  function enemy:summon()
    enemy:stop_movement() -- don't move while summoning
    local sprite = enemy:get_sprite()
    local wind_up_animation = "wind_up"
    if sprite:has_animation("summoning_wind_up") then wind_up_animation = "summoning_wind_up" end
    sprite:set_animation(wind_up_animation)
    if properties.summoning_wind_up_sound then sol.audio.play_sound(properties.summoning_wind_up_sound) end
    if properties.protected_while_summoning then
      -- enemy.hidden_invincibility = true
    end
    local telegraph_time = properties.wind_up_time
    if properties.summon_attack_wind_up_time then telegraph_time = properties.summon_attack_wind_up_time end
    sol.timer.start(map, telegraph_time, function()
      -- enemy.hidden_invincibility = false
      enemy:get_sprite():set_opacity(255)
      sol.audio.play_sound(properties.summoning_sound or "charge_1")
      local i = 0
      sol.timer.start(map, properties.summon_group_delay, function()
        if enemy:get_life() <= 0 then return end
        local herox, heroy, herol = hero:get_position()
        local summon_enemy = map:create_enemy({
          name = enemy_summon, layer = herol, x = herox, y = heroy, direction = 0, breed = properties.summon_breed,
        })
        if properties.summon_breed_damage then summon_enemy:set_damage(properties.summon_breed_damage) end
        i = i + 1
        if i < properties.summon_group_size then return true end
      end)
      enemy:wrap_up_attack()
      going_hero = false
      enemy:go_random()
      enemy:check_hero()
    end)
  end



  --Ranged Attack
  function enemy:ranged_attack()
    enemy:stop_movement()
    local sprite = enemy:get_sprite()
    sprite:set_animation("wind_up")
    if sprite:has_animation("shooting_wind_up") then sprite:set_animation("shooting_wind_up") end
    local telegraph_time = properties.ranged_telegraph_time or properties.wind_up_time or 1000
    if properties.ranged_attack_wind_up_time then telegraph_time = properties.ranged_attack_wind_up_time end
    sol.timer.start(map, telegraph_time, function()
      if enemy:get_life() <= 0 then return end
      sol.audio.play_sound(properties.ranged_attack_sound or "shoot")
      sprite:set_animation("shooting", function()
        going_hero = false
        enemy:go_random()
        enemy:check_hero()
      end)
      enemy:create_projectile()
    end)
  end
  function enemy:create_projectile()
    --get direction and position
    if enemy:get_life() <= 0 then return end
    local direction = (self:get_sprite() and self:get_sprite():get_direction() or 0)
    local x, y, layer = self:get_position()
    local dx = {[0] = 8, [1] = 0, [2] = -8, [3] = 0}
    local dy = {[0] = 0, [1] = -8, [2] = 0, [3] = 8}
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
    enemy:wrap_up_attack()
  end



  --Orbit Attack
  function enemy:orbit_attack()
    enemy:stop_movement() --don't move while summoning the orbiting projectiles
    local sprite = enemy:get_sprite()
    local x, y, layer = enemy:get_position()
    local direction = sprite:get_direction()
    local projectiles = {}
    local NUM_PROJECTILES = properties.orbit_attack_num_projectiles or 6
    local CHARGE_TIME = properties.orbit_attack_charge_time or 800
    local SHOOT_DELAY = properties.orbit_attack_shoot_delay or 1500
    if properties.orbit_attack_stop_while_charging then enemy:stop_movement() end
    sprite:set_animation("wind_up")
    if sprite:has_animation("orbit_attack_wind_up") then sprite:set_animation("orbit_attack_wind_up") end
    for i=1, NUM_PROJECTILES do
      sol.timer.start(map, CHARGE_TIME/NUM_PROJECTILES * i, function()
        if enemy:get_life() >= 1 then
          sol.audio.play_sound(properties.orbit_attack_summon_sound or "summon_in")
          projectiles[i] = map:create_enemy({
            x = x, y = y, layer = layer, direction = direction,
            breed = properties.orbit_attack_projectile_breed
          })
          local m = sol.movement.create("circle")
          m:set_center(enemy)
          m:set_radius(properties.orbit_attack_radius or 32)
          m:set_angular_speed(8)
          m:set_ignore_obstacles(true)
          m:start(projectiles[i])
        end
        if i == NUM_PROJECTILES then sprite:set_animation("walking") end
      end)
    end
    sol.timer.start(map, CHARGE_TIME + SHOOT_DELAY, function()
      sol.audio.play_sound("sword2")
      enemy:wrap_up_attack()
      local DELAY = properties.orbit_attack_projectile_delay or 300
      for i=1, #projectiles do
        if projectiles[i] and projectiles[i]:get_life() > 0 then
          sol.timer.start(map, (DELAY * i), function()
            if enemy:get_life() >= 1 then
              local m = sol.movement.create("straight")
              m:set_angle(enemy:get_angle(hero))
              m:set_speed(160)
              m:set_smooth(false)
              projectiles[i]:stop_movement()
              sol.audio.play_sound(properties.orbit_attack_launch_sound or "shoot_magic")
              m:start(projectiles[i], function() projectiles[i]:remove() end)
              function m:on_obstacle_reached() projectiles[i]:remove() end
              if properties.use_projectile_go_method then
                projectiles[i]:stop_movement()
                projectiles[i]:go(enemy:get_angle(hero))
              end
            else
              projectiles[i]:remove_life(100)
            end
          end)
        end
      end
    end)
  end

  --Radial Attack
  function enemy:radial_attack()
    -- enemy:stop_movement() --don't move while summoning the orbiting projectiles
    local sprite = enemy:get_sprite()
    local x, y, layer = enemy:get_position()
    local direction = sprite:get_direction()
    local projectiles = {}
    local NUM_PROJECTILES = properties.radial_attack_num_projectiles or 8
    local CHARGE_TIME = properties.radial_attack_charge_time or 1500
    local SHOOT_DELAY = properties.radial_attack_shoot_delay or 500
    if properties.radial_attack_stop_while_charging then enemy:stop_movement() end
    sprite:set_animation("wind_up")
    if sprite:has_animation("radial_attack_wind_up") then sprite:set_animation("radial_attack_wind_up") end
    for i=1, NUM_PROJECTILES do
      sol.timer.start(map, CHARGE_TIME / NUM_PROJECTILES * i, function()
        if enemy:get_life() >= 1 then
          sol.audio.play_sound(properties.radial_attack_summon_sound or "summon_in")
          projectiles[i] = map:create_enemy({
            x = x, y = y, layer = layer, direction = direction,
            breed = properties.radial_attack_projectile_breed
          })
          local m = sol.movement.create("circle")
          m:set_center(enemy)
          m:set_radius(properties.radial_attack_radius or 32)
          m:set_angular_speed(2 * math.pi / CHARGE_TIME * 1000)
          m:set_ignore_obstacles(true)
          m:start(projectiles[i])
          if i == NUM_PROJECTILES then sprite:set_animation("walking") end
        end --end if life >= 1
      end)
    end

    sol.timer.start(map, CHARGE_TIME, function() enemy:wrap_up_attack() end)

    sol.timer.start(map, CHARGE_TIME + SHOOT_DELAY, function()
      sol.audio.play_sound("sword2")
      sol.audio.play_sound(properties.radial_attack_launch_sound or "shoot_magic")
      for i=1, NUM_PROJECTILES do
        if projectiles[i] and projectiles[i]:get_life() > 0 then
          local m = sol.movement.create("straight")
          m:set_angle(enemy:get_angle(projectiles[i]))
          m:set_speed(160)
          m:set_smooth(false)
          if properties.radial_attack_projectiles_go_through_walls then m:set_ignore_obstacles() end
          projectiles[i]:stop_movement()
          m:start(projectiles[i], function() projectiles[i]:remove() end)
          function m:on_obstacle_reached() projectiles[i]:remove() end
          if properties.use_projectile_go_method then
            projectiles[i]:stop_movement()
            projectiles[i]:go(enemy:get_angle(hero))
          end

        end
      end
    end)
  end


  --Flail Attack
  function enemy:flail_attack()
    enemy:stop_movement()
    local sprite = enemy:get_sprite()
    sprite:set_animation("wind_up")
    if sprite:has_animation("flail_wind_up") then sprite:set_animation("flail_wind_up") end
    sol.timer.start(map, properties.flail_wind_up_time or 500, function()
      sprite:set_animation("walking")
      if sprite:has_animation("attack") then
        sprite:set_animation("attack", function() sprite:set_animation("walking") end)
      end
      if sprite:has_animation("flail_attack") then
        sprite:set_animation("flail_attack", function() sprite:set_animation("walking") end)
      end
      --Actual Attack part:
      local x, y, layer = enemy:get_position()
      local flail = enemy:create_enemy({
        x = 0, y = 0, layer = layer, direction = 0, breed = "misc/enemy_weapon"
      })
      flail:set_damage(enemy:get_damage())
      flail:create_sprite(properties.flail_sprite or "entities/spike_ball")
      local circling = true
      sol.timer.start(map, 10, function()
        if circling then
          sol.audio.play_sound("flail_swing")
          return 500
        end
      end)
      local m = sol.movement.create("circle")
      m:set_center(enemy)
      m:set_radius(1)
      m:set_radius_speed(250)
      m:set_angular_speed(10)
      m:set_max_rotations(properties.flail_max_rotations or 2)
      m:set_ignore_obstacles(true)
      m:start(flail, function()
        circling = false
        sol.audio.play_sound("flail_throw")
        local m2 = sol.movement.create("straight")
        m2:set_angle(enemy:get_angle(hero))
        m2:set_max_distance(properties.flail_max_distance or 128)
        m2:set_speed(properties.flail_speed)
        m2:set_ignore_obstacles(true)
        m2:start(flail, function()
          sol.timer.start(map, 200, function()
            local m3 = sol.movement.create("straight")
            m3:set_angle(flail:get_angle(enemy))
            m3:set_ignore_obstacles(true)
            m3:set_speed(properties.flail_speed)
            m3:set_max_distance(properties.flail_max_distance or 128)
            m3:start(flail, function()
              flail:remove()
              enemy:wrap_up_attack()
              enemy:go_random()
              enemy:check_hero()
            end)
          end)
        end)
      end)
      m:set_radius(properties.flail_radius or 48)
    end)
  end

  --Boomerang Attack
  function enemy:boomerang_attack()
    enemy:stop_movement()
    local sprite = enemy:get_sprite()
    sprite:set_animation("wind_up")
    if sprite:has_animation("boomerang_wind_up") then sprite:set_animation("boomerang_wind_up") end
    sol.timer.start(map, properties.boomerang_wind_up_time or 500, function()
      sprite:set_animation("walking")
      if sprite:has_animation("shooting") then
        sprite:set_animation("shooting", function() sprite:set_animation("walking") end)
      end
      if sprite:has_animation("boomerang_attack") then
        sprite:set_animation("boomerang_attack", function() sprite:set_animation("walking") end)
      end
      --Actual Attack part:
      local x, y, layer = enemy:get_position()
      local boomerang = enemy:create_enemy({
        name = "enemy_thrown_boomerang",
        x = 0, y = 0, layer = layer, direction = 0, breed = "misc/enemy_weapon"
      })
      boomerang:set_damage(enemy:get_damage())
      boomerang:set_obstacle_behavior("flying")
      local sprite = boomerang:create_sprite("enemies/misc/boomerang")

      --sound
      sol.timer.start(enemy, 160, function()
        if enemy:get_map():has_entities("enemy_thrown_boomerang") then
          sol.audio.play_sound("boomerang")
          return true
        end
      end)

      local m2 = sol.movement.create("straight")
      m2:set_angle(enemy:get_angle(hero))
      m2:set_max_distance(properties.boomerang_max_distance or 128)
      m2:set_speed(properties.boomerang_speed or 150)
      m2:set_ignore_obstacles(false)
      m2:start(boomerang, function()
        sol.timer.start(map, 200, function()
          local m3 = sol.movement.create("straight")
          m3:set_angle(boomerang:get_angle(enemy))
          m3:set_ignore_obstacles(true)
          m3:set_speed(properties.boomerang_speed or 150)
          m3:set_max_distance(properties.boomerang_max_distance or 128)
          m3:start(boomerang, function()
            boomerang:remove()
            enemy:wrap_up_attack()
            enemy:go_random()
            enemy:check_hero()
          end)
        end)
      end)

      function m2:on_obstacle_reached()
        sol.audio.play_sound("thunk1")
        boomerang:remove()
        enemy:wrap_up_attack()
        enemy:go_random()
        enemy:check_hero()
      end

    end)
  end

  --Airstrike Attack
  function enemy:airstrike()
    enemy:stop_movement()
    local sprite = enemy:get_sprite()
    if properties.airstrike_sound then sol.audio.play_sound(properties.airstrike_sound) end
    sprite:set_animation("airstrike")
    local frames = sprite:get_num_frames()
    local delay = sprite:get_frame_delay()
    local animation_time = frames * delay
    sol.timer.start(map, animation_time, function()
      local i = properties.airstrike_num_projectiles or 1
      sol.timer.start(map, properties.airstrike_lag, function()
        local map = enemy:get_map()
        local x,y,l = map:get_hero():get_position()
        local strike_enemy = map:create_enemy{
          x=x,y=y,layer=l,direction=0,
          breed=properties.airstrike_breed or "misc/falling_rock"
        }
        if properties.airstrike_damage then strike_enemy:set_damage(properties.airstrike_damage) end
        if i > 1 then i = i -1 return math.random(100,500) end
      end)
      enemy:wrap_up_attack()
      enemy:go_random()
      enemy:check_hero()
    end)
  end


  --Surround the hero with projectiles
  function enemy:surround_attack()
    local fires = {}
    local sprite = enemy:get_sprite()
    local NUM_PROJECTILES = properties.surround_attack_num_projectiles or 6
    local RADIUS = properties.surround_attack_radius or 112
    local DELAY = properties.surround_attack_delay or 2500
    local ZOOM_SPEED = properties.surround_attack_zoom_speed or 120

    sprite:set_animation(properties.surround_attack_wind_up_sprite or "wind_up")
    enemy:stop_movement()
    sol.timer.start(map, 800, function()
      sprite:set_animation("walking")
      sol.audio.play_sound(properties.surround_attack_appear_sound or "fire_burst_1")
      for i=1, NUM_PROJECTILES do
        fires[i] = enemy:create_enemy{breed = properties.surround_attack_breed or "misc/blue_fire"}
        local m = sol.movement.create("circle")
        m:set_center(hero)
        m:set_radius(RADIUS)
        m:set_angle_from_center(math.pi * 2 / NUM_PROJECTILES * i)
        m:set_angular_speed(2)
        m:set_ignore_obstacles()
        m:start(fires[i])
      end

      sol.timer.start(map, DELAY, function()
        sol.audio.play_sound(properties.surround_attack_shoot_sound or "shoot_magic_2")
        for i=1, NUM_PROJECTILES do
          if fires[i] then
            local m = sol.movement.create("straight")
            m:set_speed(ZOOM_SPEED)
            m:set_angle(fires[i]:get_angle(hero))
            m:set_max_distance(fires[i]:get_distance(hero))
            m:set_ignore_obstacles()
            m:start(fires[i])
            function m:on_finished()
              fires[i]:remove()
            end
          end
        end
      end)

      sol.timer.start(map, 2000, function()
        enemy:wrap_up_attack()
        enemy:go_random()
        enemy:check_hero()
      end)

    end)
  end

  --Null Test attack
  function enemy:null_test_attack()
    -- print("Null test attack", os.time())
    enemy:wrap_up_attack()
  end

end --end of bahavior:create() fuction

return behavior
