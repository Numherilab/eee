-- Lua script of map new_limestone/basswood_tavern.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local talked_to_linden

map:register_event("on_started", function()

end)


function talk_to_dad_sensor:on_activated()
local dad_counter = game:get_value("dad_dialog_counter_tavern")
if dad_counter == nil then
  local see_dad_movement = sol.movement.create("target")
  hero:freeze()
  see_dad_movement:set_target(128, 96)
  hero:set_direction(0)
  hero:set_animation("walking")
  see_dad_movement:start(hero, function()
    game:start_dialog("_new_limestone_island.npcs.mallow.1", function()
      game:set_value("linden_intro_dialog", true)
      hero:unfreeze()
      game:set_value("dad_dialog_counter_tavern", 1)
      game:set_value("quest_whisky_for_juglan_phase", 0) --quest log

      end)
  end)
end
end

function linden:on_interaction()
  if talked_to_linden == true then
    game:start_dialog("_new_limestone_island.npcs.linden.2")
  else
    game:start_dialog("_new_limestone_island.npcs.linden.1")
    talked_to_linden = true
  end

end
