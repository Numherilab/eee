require("scripts/multi_events")

local item = ...
local game = item:get_game()
local map
local hero
local sprite
local MAX_BOUNCES = 4
local SPEED = 150

item:register_event("on_created", function(self)
  item:set_savegame_variable("possession_homing_eye")
  item:set_amount_savegame_variable("amount_homing_eye")
  item:set_assignable(true)
end)

item:register_event("on_obtaining", function(self, variant)
  item:add_amount(10)
end)


item:register_event("on_using", function(self)
  if item:get_amount() > 0 then
    item:remove_amount(1)
    map = game:get_map()
    hero = game:get_hero()
    sprite = hero:get_sprite()
    hero:freeze()
    sol.audio.play_sound"throw"
    sprite:set_animation("throwing", function()
      hero:unfreeze()
      sprite:set_animation("stopped")
    end)
    local x,y,l = hero:get_position()
    local bomb = map:create_custom_entity({
      direction = 0, x = x, y = y, layer = l, width = 16, height = 16,
      sprite = "entities/homing_eye"
    })
    bomb:set_can_traverse_ground("deep_water", true)
    bomb:set_can_traverse_ground("shallow_water", true)
    bomb:set_can_traverse_ground("hole", true)
    bomb:set_can_traverse_ground("lava", true)
    bomb:set_can_traverse("hero", true)
    bomb.bounces = 0

    --damage enemies if you hit them
    bomb.attacking = false
    bomb:add_collision_test("sprite", function(bomb, other_entity)
      if other_entity:get_type() == "enemy"
      and not attacking
      and other_entity:get_attack_consequence("sword") ~= "ignore"
      and other_entity:get_attack_consequence("sword") ~= "protected"
      then
        bomb.attacking = true
        sol.timer.start(map, 200, function() bomb.attacking = false end)
        other_entity:hurt(game:get_value("sword_damage"))
      end
    end)

    --find a nearby enemy
    local target_enemy = nil
    for entity in map:get_entities_in_region(hero) do
      if entity:get_type() == "enemy" and hero:get_distance(entity) < 416 then
        if target_enemy then
          if hero:get_distance(target_enemy) > hero:get_distance(entity) then
            target_enemy = entity
          end
        else
          target_enemy = entity
        end
      end
    end
    local angle = sprite:get_direction() * math.pi / 2
    if target_enemy then angle = hero:get_angle(target_enemy) end
    item:go(bomb, angle)

    item:set_finished()
  else
    sol.audio.play_sound"no"
    item:set_finished()
  end
end)

function item:go(bomb, angle)
  local m = sol.movement.create("straight")
  m:set_speed(SPEED)
  m:set_angle(angle)
  m:set_smooth(false)
  m:start(bomb)
  function m:on_obstacle_reached()
    if bomb.bounces < MAX_BOUNCES then
      bomb.bounces = bomb.bounces + 1
      item:go(bomb, item:get_new_direction(bomb))
    else
      local x,y,l = bomb:get_position()
      local poof = map:create_custom_entity({x=x,y=y,layer=l,direction=0,width=16,height=16,sprite="entities/bush"})
       poof:get_sprite():set_animation("destroy", function() poof:remove() end)
      bomb:remove()
    end
  end
end

function item:get_new_direction(bomb)
  local wall_orientation = item:get_collision_wall_orientation(bomb)
  local current_angle = bomb:get_movement():get_angle()
  local new_angle
  if wall_orientation == "vertical" then
    new_angle = math.pi - current_angle
  else
    new_angle = 2*math.pi - current_angle
  end  
  return new_angle
end

function item:get_collision_wall_orientation(bomb)
  if bomb:test_obstacles(8, 0) or bomb:test_obstacles(-8, 0) then return "vertical"
  else return "horizontal" end
end