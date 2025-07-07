-- Lua script of map Limestone Island/intro_map.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  intro_warp:set_enabled(false)
---juglan movement
  local juglan_movement = sol.movement.create("random_path")
  juglan_movement:set_speed(20)
  juglan_movement:start(juglan)
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function mallow:on_interaction()
  game:start_dialog("_limestone_island.npcs.mallow.1", function () 
  intro_warp:set_enabled(true)
  end)
end