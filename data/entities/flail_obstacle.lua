local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local destroyed

local function destroy_self()
  if not destroyed then
    destroyed = true
    sol.audio.play_sound("running_obstacle")
    if entity:get_sprite():has_animation("destroy") then
      entity:get_sprite():set_animation("destroy", function()
        entity:remove()
      end)
    else
      entity:remove()
    end
  end
end

function entity:on_created()
  destroyed = false
  entity:set_drawn_in_y_order(true)
  entity:set_modified_ground("wall")

  --collision tests
  entity:add_collision_test("sprite", function(entity, other_entity)

    if other_entity:get_name() == "flail_chain_link" or other_entity:get_name() == "flail_spike_ball" then
      destroy_self()
    end

    if other_entity:get_type() == "custom_entity" and other_entity:get_model() == "toss_ball" then
      destroy_self()
    end
  end)


end