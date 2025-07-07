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

local MAGIC_COST = 15

item:register_event("on_created", function(self)

  item:set_savegame_variable("possession_bow_warp")
  item:set_assignable(true)
end)

item:register_event("on_started", function(self)
end)


-- set to item slot 1
item:register_event("on_obtained", function(self)
--increase bow damage
  game:set_value("bow_damage", game:get_value("bow_damage") + 2)
end)


-- Using the bow.

item:register_event("on_using", function(self)
  local map = game:get_map()
  local hero = map:get_hero()

  if game:get_magic() < MAGIC_COST or not game:has_item"bow" then
    sol.audio.play_sound("no")
    self:set_finished()
  else
    game:remove_magic(MAGIC_COST)
    hero:set_animation("bow")

    sol.timer.start(map, 290, function()
    sol.audio.play_sound("bow")
      --Save hero's location to move block to
      hero.warp_arrow_x, hero.warp_arrow_y, hero.warp_arrow_z = hero:get_position()
      self:set_finished()

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
         model = "arrow_warp",
       })

      arrow:set_sprite_id("entities/arrow_warp")
      arrow:go()

    end)
  end
end)
