local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local hero = entity:get_game():get_hero()
local being_destroyed

local function destroy_self()
  entity:clear_collision_tests()
  sol.audio.play_sound("running_obstacle")
  entity:get_sprite():set_animation("destroy", function()
    entity:set_enabled(false)
  end)
end
 

function entity:on_created()
  entity:set_modified_ground("wall")
  being_destroyed = false
  entity:add_collosion_test("touching", function()
    if game:get_value"hero_dashing" or hero:get_state() == "running" then
      if not being_destroyed then destroy_self() end
      being_destroyed = true
    end
  end)
end
