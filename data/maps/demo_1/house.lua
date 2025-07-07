-- Lua script of map demo_1/house.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function smith_guy:on_interaction()

if game:get_value("demo_1_smith") == true then

else
  game:start_dialog("demo_1.npcs.smith_guy.1", function()
      sol.audio.play_sound("treasure")
      game:start_dialog("_treasure.sword_upgrade.1")
      local sword_damage =   game:get_value("sword_damage")
      game:set_value("sword_damage", sword_damage + 1)
      game:set_value("demo_1_smith", true)
  end) --end of start dialog method
end

end