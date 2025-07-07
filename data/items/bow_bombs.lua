-- The bow has two variants: without arrows or with arrows.
-- This is necessary to allow it to have different icons in both cases.
-- Therefore, the silver bow is implemented as another item (bow_silver),
-- and calls code from this bow.
-- It could be simpler if it was possible to change the icon of items dynamically.

-- Max addendum: no. Different bow/arrow items are different items. They shoot different arrow entities.
-- The only similarity is that the arrow pickups on the map refil all bow types.

require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_created", function(self)

  item:set_savegame_variable("possession_bow_bombs")
  item:set_amount_savegame_variable("amount_bow")
  item:set_assignable(true)
end)

item:register_event("on_started", function(self)
  item:set_max_amount(999)
end)


-- set to item slot 1
item:register_event("on_obtained", function(self)
--increase bow damage
  bow_damage = game:get_value("bow_damage")
  bow_damage = bow_damage + 1
  game:set_value("bow_damage", bow_damage)
  game:set_value("quest_bomb_arrows", 5) --quest log
end)


-- Using the bow.

item:register_event("on_using", function(self)

  local map = game:get_map()
  local hero = map:get_hero()

  if self:get_amount() == 0 or not game:has_item"bow" then
    sol.audio.play_sound("no")
    self:set_finished()
  else
    hero:set_animation("bow")

    sol.timer.start(map, 290, function()
    sol.audio.play_sound("bow")
      self:remove_amount(1)
      self:set_finished()
--also, shoot a normal arrow so we can activate switches and stuff.
--actually, this causes a whole bunch of problems. Find a way to make this entity activate switches for real or else avoid that possibility in game.
--      hero:start_bow()

       local x, y = hero:get_center_position()
       local _, _, layer = hero:get_position()
       local dx = {[0]=8, [1]=0, [2]=-8, [3]=0}
       local dy = {[0]=0, [1]=-8, [2]=0, [3]=8}
       local direction = hero:get_direction()
       local arrow = map:create_custom_entity({
         x = x + dx[direction],
         y = y + dy[direction],
         layer = layer,
         width = 16,
         height = 16,
         direction = hero:get_direction(),
         model = "arrow_bomb",
       })


      arrow:set_force(self:get_force())
      arrow:set_sprite_id(self:get_arrow_sprite_id())
      arrow:go()

    end)
  end
end)


function item:get_force()

  return 2
end


-- Set the sprite for the arrow entity

function item:get_arrow_sprite_id()
     return "entities/arrow_fire"

end
