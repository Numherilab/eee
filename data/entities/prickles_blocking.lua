local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local hero = map:get_hero()
local currently_hurting =false

function entity:on_created()
  entity:set_direction(0)
  entity:set_tiled(true)
  entity:set_traversable_by(false)
  entity:add_collision_test("touching", function(entity, other_entity)
    if other_entity:get_type() == "hero" and not currently_hurting then
      currently_hurting = true
      hero:start_hurt(entity, 1)
      sol.timer.start(map, 1000, function() currently_hurting = false end)
    end
  end)
end
