require("scripts/multi_events")

local item = ...
local game = item:get_game()
local map
local hero
local sprite

item:register_event("on_created", function(self)
  item:set_savegame_variable("possession_ether_bombs")
  item:set_amount_savegame_variable("amount_ether_bombs")
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
      sprite = "entities/ether_bomb"
      --model = "ether_bomb"
    })
    local m = sol.movement.create("jump")
    m:set_direction8(sprite:get_direction()*2)
    m:set_distance(48)
    m:set_speed(100)
    m:start(bomb)
    sol.timer.start(map, 200, function() bomb:get_sprite():set_animation("sparking") end)
    sol.timer.start(map, 1000, function()
      item:explode_bomb(bomb)
    end)
    item:set_finished()
  else
    sol.audio.play_sound"no"
    item:set_finished()
  end
end)

item:register_event("explode_bomb", function(self, bomb)
  local x,y,l = bomb:get_position()
  local dist = 24
  local dx = {0,dist,0,(dist * -1),0}
  local dy = {0,0,dist,0,(dist * -1)}
  sol.audio.play_sound"explosion_ice"
  for i=1, 5 do
    local explosion = map:create_custom_entity({
      direction=0, x = x + dx[i], y = y + dy[i], layer = l, width = 64, height = 64,
      sprite = "entities/explosion_blue"
    })
    explosion:get_sprite():set_animation("explosion", function() explosion:remove() end)
    explosion:add_collision_test("sprite", function(explosion, other_entity)
      if other_entity:get_type() == "enemy" then
        if not other_entity.immobilize_immunity then
          other_entity:immobilize()
        end
      end
    end)
  end
  bomb:remove()
end)
