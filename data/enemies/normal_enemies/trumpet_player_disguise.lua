local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement
local dashing
--adjustable stats
local detection_distance = 65
local walking_speed = 45
local running_speed = 77
local dash_distance = 80
local dash_speed = 140
enemy.height = 16


function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(30)
  enemy:set_damage(1)
enemy:set_dying_sprite_id("enemies/enemy_killed_ko")
end

function enemy:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  sprite = self:get_sprite()
  sprite:set_direction(direction4)
end

function enemy:on_restarted()
  if moement ~= nil then movement:stop() end
  dashing = false
  enemy:go_random()
  enemy:check_hero()
end

function enemy:check_hero()
  local dist_hero = enemy:get_distance(hero)
  local _,_,hero_layer = hero:get_position()
  local _,_,enemy_layer = enemy:get_position()
  if enemy_layer == hero_layer and dist_hero < detection_distance and not dashing then
    enemy:run_away()
  elseif not dashing then
    enemy:go_random()
  end

  sol.timer.start(enemy, 100, function() enemy:check_hero() end)

end

function enemy:run_away()
  local angle = enemy:get_angle(hero)
  angle = angle + math.pi
  movement = sol.movement.create("straight")
  movement:set_angle(angle)
  movement:set_speed(running_speed)
  movement:start(enemy)  
end

function enemy:go_random()
  movement = sol.movement.create("random_path")
  movement:set_speed(walking_speed)
  movement:start(enemy)
end

function enemy:on_obstacle_reached()
  enemy:dash()
end

function enemy:dash()
  dashing = true
  movement = sol.movement.create("straight")
  movement:set_angle(math.random(2*math.pi))
  movement:set_speed(dash_speed)
  movement:set_max_distance(dash_distance)
  movement:start(enemy, function()
    dashing = false
    enemy:go_random()
  end) 
end

function enemy:on_dying()
  if map:has_entity("brian") then
    local trumpet_player = map:get_entity("brian")
    local enemy_x,enemy_y,enemy_layer = enemy:get_position()
    trumpet_player:set_position(enemy_x, enemy_y, enemy_layer)
    hero:freeze()
    sol.timer.start(1500, function()
      hero:unfreeze()
      game:set_value("oakhaven_find_poster_monster", false)
      game:set_value("oakhaven_musicians_saved", true)
      game:set_value("gunther_counter", 4)
      game:start_dialog("_oakhaven.npcs.musicians.brian.caught", function()
        trumpet_player:set_traversable(true)
        game:set_value("quest_oakhaven_musicians", 3) --quest log
      end)
    end)
  end
  

end