--[[
This is to replace the built-in fire from the engine, which is called with map:create_fire()
--]]
local fire = ...
local sprite
local game = fire:get_game()
local map = fire:get_map()


fire:set_can_traverse("crystal", true)
fire:set_can_traverse("crystal_block", true)
fire:set_can_traverse("hero", true)
fire:set_can_traverse("jumper", true)
fire:set_can_traverse("stairs", true)
fire:set_can_traverse("stream", true)
fire:set_can_traverse("switch", true)
fire:set_can_traverse("teletransporter", true)
fire:set_can_traverse_ground("deep_water", true)
fire:set_can_traverse_ground("shallow_water", true)
fire:set_can_traverse_ground("hole", true)
fire:set_can_traverse_ground("lava", true)
fire:set_can_traverse_ground("prickles", true)
fire:set_can_traverse_ground("low_wall", true)

fire:set_drawn_in_y_order(true)

function fire:on_created()
  sprite = fire:get_sprite()
  local animations = {"fire_a", "fire_b"}
  sprite:set_animation(animations[math.random(1,2)], function() fire:remove() end)
--  sprite:set_blend_mode"add"
--[[  local second_sprite = fire:create_sprite("entities/fire")
  second_sprite:set_animation(animations[math.random(1,2)])
  second_sprite:set_blend_mode"add"
--]]
end



-- Collision
local burned_entities = {}
fire:add_collision_test("sprite", function(fire, entity)
  --Don't do callback twice for same entity
  if burned_entities[entity] then return end
  burned_entities[entity] = true

--  print"COLLISION"
--  print("NAME: ", entity:get_name())
--  print("TYPE: ", entity:get_type())
--  print" "

  if entity.on_collision_fire then 
    entity:on_collision_fire()
  end

  --Hurt enemies
  if entity:get_type() == "enemy" then
    local enemy = entity
    local reaction = enemy:get_attack_consequence("fire")
    if reaction ~= "protected" and reaction ~= "ignored" then
      local damage = game:get_value("sword_damage")
      if enemy.weak_to_fire then damage = damage * 2 end
      enemy:react_to_fire()
      enemy:hurt(damage)
    end
  end

  --Burn bushes
  if entity:get_type() == "destructible" then
    local sprite_name = entity:get_sprite():get_animation_set()
    if string.match(sprite_name, "bush") then
      if entity.burning_bush then fire:clear_collision_tests() end
      entity.burning_bush = true
      sol.audio.play_sound("bush")
      local x,y,z = entity:get_position()
      entity:remove()
      map:create_fire{x=x,y=y,layer=z}
      sol.audio.play_sound"fire_burst_3"
      sol.timer.start(map, 100, function()

--Static Fire:
--[[
        local dx = {8,0,-8,0}
        local dy = {0,-8,0,8}
        for i=1, 4 do
          map:create_fire{
            x=x + dx[i], y=y + dy[i], layer=z
          }
        end
--]]
--Moving Fire:
        local NUM_PROP_FLAMES = 5
        for i=1, NUM_PROP_FLAMES do
          local flame = map:create_fire{
            x=x, y=y, layer=z
          }
          local m = sol.movement.create"straight" m:set_speed(70) m:set_max_distance(12)
          m:set_angle(2*math.pi / NUM_PROP_FLAMES * i)
          m:set_ignore_obstacles(true)
          m:start(flame)
        end
-- Wayy too much fire if you want to just break the game:
--[[
        local SPEWSPEW = 10
        for i=1, SPEWSPEW do
          local flame = map:create_fire{
            x=x, y=y, layer=z
          }
          local m = sol.movement.create"straight" m:set_speed(200) m:set_max_distance(280)
          m:set_angle(2*math.pi / SPEWSPEW * i)
          m:start(flame)
        end
--]]
      end)
    end
  end
end)