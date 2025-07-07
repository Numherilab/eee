require("scripts/multi_events")

local item = ...
local game = item:get_game()
local map
local hero
local sprite
local NUM_EXPLOSIONS = 6
local DISTANCE = 250
local EXP_DELAY = 250
local SPEED = 200

item:register_event("on_created", function(self)
  item:set_savegame_variable("possession_iron_candle")
  item:set_amount_savegame_variable("amount_iron_candle")
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
      sprite = "entities/iron_candle",
      name = "iron_candle_entity",
    })
    local m = sol.movement.create("straight")
    local dirToRad = {0, math.pi/2, math.pi, (2+1)*math.pi/2} --three button is broken right now ahhhh
    m:set_angle(dirToRad[sprite:get_direction()+1])
    m:set_max_distance(DISTANCE)
    m:set_speed(SPEED)
    m:start(bomb)
    sol.timer.start(map, 200, function() bomb:get_sprite():set_animation("sparking") end)
    sol.audio.play_sound"ether_bomb"
    local i = 0
    sol.timer.start(game:get_map(), EXP_DELAY, function()
      item:explode_bomb(bomb)
      i = i + 1
      if i < NUM_EXPLOSIONS then
        return true
      else
        item:explode_bomb(bomb)
        bomb:remove() 
      end
    end)
    item:set_finished()
  else
    sol.audio.play_sound"no"
    item:set_finished()
  end
end)

item:register_event("explode_bomb", function(self, bomb)
    local x,y,l = bomb:get_position()
    sol.audio.play_sound"hand_cannon"
    map:create_explosion{
      x=x, y=y, layer=l
    }
    local explosion = map:create_custom_entity({
      direction=0, x = x, y = y, layer = l, width = 64, height = 64,
      sprite = "entities/explosion_3", model = "damaging_sparkle"
    })
    explosion:set_damage(game:get_value"sword_damage" * .75)
    explosion:get_sprite():set_animation("explosion", function() explosion:remove() end)
end)






----------------------------------------------------------
--================OLD BEHAVIOR==========================--
----------------------------------------------------------

--[[

require("scripts/multi_events")

local item = ...
local game = item:get_game()
local map
local hero
local sprite
local NUM_EXPLOSIONS = 4

item:register_event("on_created", function(self)
  item:set_savegame_variable("possession_iron_candle")
  item:set_amount_savegame_variable("amount_iron_candle")
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
      sprite = "entities/iron_candle",
      name = "iron_candle_entity",
    })
    local m = sol.movement.create("jump")
    m:set_direction8(sprite:get_direction()*2)
    m:set_distance(48)
    m:set_speed(100)
    m:start(bomb)
    sol.timer.start(map, 200, function() bomb:get_sprite():set_animation("sparking") end)
    sol.audio.play_sound"ether_bomb"
    item:explode_bomb(bomb)
    item:set_finished()
  else
    sol.audio.play_sound"no"
    item:set_finished()
  end
end)

item:register_event("explode_bomb", function(self, bomb)
  local i = 0
  sol.timer.start(map, 2000, function()
    local x,y,l = bomb:get_position()
    sol.audio.play_sound"hand_cannon"
    local explosion = map:create_custom_entity({
      direction=0, x = x, y = y, layer = l, width = 64, height = 64,
      sprite = "entities/explosion_3", model = "damaging_sparkle"
    })
    explosion:get_sprite():set_animation("explosion", function() explosion:remove() end)
    i = i + 1
    if i < 4 then
      sol.audio.play_sound"ether_bomb"
      return true
    else bomb:remove()
    end
  end) --end of timer
 
end)
-- ]]
