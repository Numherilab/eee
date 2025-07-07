local item = ...
local game = item:get_game()

local state

function item:on_started()
  local name = item:get_name():gsub("/", "_")
  item:set_savegame_variable("possession_" .. name)

    state = sol.state.create()
    state:set_description("debug_fly")
    state:set_can_control_movement(true)
    state:set_visible(true)
    state:set_can_traverse(true)
    state:set_can_traverse_ground("wall", true)
    state:set_can_traverse_ground("low_wall", true)
    state:set_can_traverse_ground("deep_water", true)
    state:set_can_traverse_ground("hole", true)
    state:set_can_traverse_ground("prickles", true)
    state:set_gravity_enabled(false)
    state:set_affected_by_ground("ladder", false)
    state:set_can_be_hurt(false)
end

function item:on_using()
  local hero = game:get_hero()
  local map = game:get_map()
  local hero_state, state_object = hero:get_state()
  if hero_state == "custom" and state_object:get_description() == "debug_fly" then
    hero:unfreeze()
  else
    hero:start_state(state)
    hero:set_layer(map:get_max_layer())
  end
  item:set_finished()
end
