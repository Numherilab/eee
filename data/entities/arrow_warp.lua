local arrow = ...
local game = arrow:get_game()
local map = arrow:get_map()
local hero = map:get_hero()
local direction = hero:get_direction()
local sprite_id
local sprite
local flying
local enemies_touched = {}


function arrow:on_created()
  local direction = arrow:get_direction()
  local horizontal = direction % 2 == 0
  if horizontal then
    arrow:set_size(16, 8)
    arrow:set_origin(8, 4)
  else
    arrow:set_size(8, 16)
    arrow:set_origin(4, 8)
  end

  local bow = game:get_item("bow")
  force = bow_damage

end

-- Traversable rules.
arrow:set_can_traverse("crystal", true)
arrow:set_can_traverse("crystal_block", true)
arrow:set_can_traverse("custom_entity", true)
arrow:set_can_traverse("hero", true)
arrow:set_can_traverse("jumper", true)
arrow:set_can_traverse("stairs", false)
arrow:set_can_traverse("stream", true)
arrow:set_can_traverse("switch", true)
arrow:set_can_traverse("teletransporter", true)
arrow:set_can_traverse_ground("deep_water", true)
arrow:set_can_traverse_ground("shallow_water", true)
arrow:set_can_traverse_ground("hole", true)
arrow:set_can_traverse_ground("lava", true)
arrow:set_can_traverse_ground("prickles", true)
arrow:set_can_traverse_ground("low_wall", true)
arrow:set_can_traverse_ground("wall_top_right", true)
arrow:set_can_traverse_ground("wall_top_left", true)
arrow:set_can_traverse_ground("wall_bottom_left", true)
arrow:set_can_traverse_ground("wall_bottom_right", true)
arrow:set_can_traverse_ground("wall_top_right_water", true)
arrow:set_can_traverse_ground("wall_top_left_water", true)
arrow:set_can_traverse_ground("wall_bottom_left_water", true)
arrow:set_can_traverse_ground("wall_bottom_right_water", true)
arrow.apply_cliffs = true


local function warp_hero(entity)
    enemy_x, enemy_y, enemy_layer = entity:get_position()
    if entity:get_type() == "enemy" then entity:stop_movement() end
    sol.audio.play_sound("charge_1")
    hero:freeze()
    hero:set_animation("arrow_warping", function()
      local camera = map:get_camera()
      local hero_x, hero_y, hero_layer = hero:get_position()
      --lock camera
      local new_layer = hero_layer + 1
      if new_layer > map:get_max_layer() then new_layer = new_layer - 2 end
      local tracking_object = map:create_custom_entity{
        direction = 0, x = hero_x, y = hero_y, layer = new_layer,
        width = 16, height = 16,
      }
      tracking_object:set_can_traverse(true)
      tracking_object:set_can_traverse("custom_entity", true)
      tracking_object:set_can_traverse_ground("wall", true)
      tracking_object:set_can_traverse_ground("deep_water", true)
      tracking_object:set_can_traverse_ground("prickles", true)
      tracking_object:set_can_traverse_ground("lava", true)
      camera:start_tracking(tracking_object)

      local poof1 = map:create_custom_entity{
        direction = 0, x = hero_x, y = hero_y+2, layer = hero_layer,
        width = 32,
        height = 32,
        sprite = "entities/poof",
        model = "ephemeral_effect"
      }
      local poof2 = map:create_custom_entity{
        direction = 0, x = enemy_x, y = enemy_y+2, layer = enemy_layer,
        width = 32,
        height = 32,
        sprite = "entities/poof",
        model = "ephemeral_effect"
      }
      poof1:start()
      poof2:start()
      hero:set_position(enemy_x, enemy_y, enemy_layer)
      entity:set_position(hero.warp_arrow_x, hero.warp_arrow_y, hero.warp_arrow_z)
      hero:set_animation("stopped")
      --move camera to hero
      local m = sol.movement.create("target")
      m:set_speed(200)
      m:start(tracking_object, function()
        hero:unfreeze()
        camera:start_tracking(hero)
        poof1:remove()
        poof2:remove()
        tracking_object:remove()
      end)
    end)
end



-- Hurt enemies and Warp
arrow:add_collision_test("sprite", function(arrow, entity)
  if entity:get_type() == "custom_entity" and entity:get_model() == "warp_block" then
    sol.audio.play_sound"drip"
    sol.audio.play_sound"hookshot"
    warp_hero(entity)
    arrow:remove()
  end
--TODO add functionality for activating ancient statues or something? Like:
--if entity:get_type() == "custom_entity" and entity:get_model() == "ancient_statue" then
    --entity:react_to_warp_arrow()
--end

  if entity:get_type() == "enemy" then
    local enemy = entity
    if enemies_touched[enemy] then
      -- If protected we don't want to play the sound repeatedly.
      return
    end
    enemies_touched[enemy] = true
    local arrow_reaction = enemy:get_attack_consequence_sprite(sprite, "arrow")
    if arrow_reaction ~= "protected" and arrow_reaction ~= "ignored" then
      bow_damage = game:get_value("bow_damage")
      enemy:hurt(bow_damage)
--      warp_hero(entity)
      arrow:remove()
    end

  end
end)



--NOTE TO SELF: The acceptable sprites for switchs are hard coded in. If you make a new switch sprite, make sure you add it
--to the list of acceptable sprites for switches to have.

arrow:add_collision_test("overlapping", function(arrow, entity)

  local entity_type = entity:get_type() --this should be a string

  if entity_type == "crystal" then
    --activate the crystal
    if flying then
      sol.audio.play_sound("switch")
      map:change_crystal_state()
      arrow:remove()
    end --end of if flying

  elseif entity_type == "switch" and not entity:is_walkable() then
    --activate the switch you hit if it's solid or arrow-type
    local switch = entity
    local sprite = switch:get_sprite()
    --check if the switch's sprite is the right type for activating
    if flying and sprite ~= nil and
    (sprite:get_animation_set() == "entities/switch_solid" or "entities/switch_lever_1" or "entities/switch_arrow") then
 
      --if it's off, turn it on. Or vice-versa.
      if not switch:is_activated() then
        sol.audio.play_sound("switch")
        switch:set_activated(true)
        switch:on_activated()
      else
        sol.audio.play_sound("switch")
        switch:set_activated(false)
        if switch.on_inactivated then switch:on_inactivated() end
      end
      arrow:remove()

    end --end of if flying and if the switch's sprite is an accepted type for activation

  end  --end of what type of entity you hit

end) --end of collision test callback function




function arrow:get_sprite_id()
  return sprite_id
end

function arrow:set_sprite_id(id)
  sprite_id = id
end

function arrow:go()

  local sprite_id = arrow:get_sprite_id()
  sprite = arrow:create_sprite(sprite_id)
  sprite:set_animation("flying")
  sprite:set_direction(direction)

  local movement = sol.movement.create("straight")
  local angle = direction * math.pi / 2
  movement:set_speed(192)
  movement:set_angle(angle)
  movement:set_smooth(false)
  movement:set_max_distance(500)
  movement:start(arrow, function() arrow:remove() end)
  flying = true
end

function arrow:on_obstacle_reached()

  arrow:remove()
end