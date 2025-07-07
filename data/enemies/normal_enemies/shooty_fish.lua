local enemy = ...

local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement
enemy.immobilize_immunity = true
local properties = {
  sprite = "enemies/" .. enemy:get_breed(),
  life = 2,
  damage = 1,
  burrow_sound = "splash",
  obstacle_behavior = "swimming",
  projectile_breed = "misc/energy_ball_small",
  projectile_damage = 2,
  time_aboveground = 2000
  
}

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(10)
  enemy:set_damage(8)
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_obstacle_behavior"swimming"
end

function enemy:on_restarted()
  enemy:dive()
  enemy:go_random()
end

function enemy:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  sprite:set_direction(direction4)
end

function enemy:go_random()
  local m = sol.movement.create"random_path"
  m:set_speed(32)
  m:start(enemy)
end

local retreating_from_land
function enemy:on_position_changed()
  local x,y,z = enemy:get_facing_position()
  local map = enemy:get_map()
--  local ground = map:get_ground(x,y,z)
  local ground = enemy:get_ground_below()
--  if gound ~= "deep_water" and ground ~= "shallow_water" and not retreating_from_land then
  if ground == "deep_water" then return
  elseif ground == "shallow_water" then return
  elseif retreating_from_land then return
  else
    --enemy is out of the water
    retreating_from_land = true
    local m = enemy:get_movement()
    local angle = m:get_angle() + math.pi
    enemy:stop_movement()
    m = sol.movement.create"straight"
    m:set_angle(angle)
    m:set_max_distance(4)
    m:set_speed(80)
    m:start(enemy, function()
      retreating_from_land = false
      enemy:go_random()
    end)
  end

end



function enemy:dive()
  if enemy:get_distance(hero) < 250 then sol.audio.play_sound"splash" end
  sprite:set_animation("underground")
  enemy:set_invincible()
  local x,y,z = enemy:get_position()
  local splash = map:create_custom_entity{
    x=x,y=y,layer=z,width=16,height=16,direction=0,
    sprite = "entities/splash"
  }
  sol.timer.start(map, 1000, function() splash:remove() end)
  sol.timer.start(map, math.random(1000, 5000), function()
    if enemy:exists() and enemy:is_enabled() then enemy:surface() end
  end)
end

function enemy:surface()
  sprite:set_animation("burrowing")
  sol.timer.start(map, 1000, function()
    enemy:set_default_attack_consequences()
    sprite:set_animation("walking")
    if enemy:get_distance(hero) < 120 then enemy:shoot() end
    sol.timer.start(enemy, 2000, function()
      enemy:dive()
    end)
  end)
end

function enemy:shoot()
  local x, y, layer = enemy:get_position()
  local direction = sprite:get_direction()
  sprite:set_animation("shooting")
  sol.audio.play_sound("stone")
  --create projectile
  local projectile = enemy:create_enemy({
    x = 0, y = 0, layer = layer, direction = direction,
    breed = properties.projectile_breed
  })
  projectile:go(enemy:get_angle(hero))
  sprite:set_animation("walking")
end
