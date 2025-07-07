-- Lua script of map demo_1/plateau_3.
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

  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function stair_sensor:on_activated()
local x, y, layer = hero:get_position()
layer = layer + 1
hero:set_position(x, y, layer)
end


function seed_spot:on_interaction()
if game:has_item("watering_can") == true then
  game:start_dialog("seed_spot.water", function(answer)
   if answer == 2 then
     vine_1:set_enabled(true)
     vine_2:set_enabled(true)
     vine_3:set_enabled(true)
     vine_4:set_enabled(true)
     seed_spot:set_enabled(false)
   end
  end) --end of start dialog method

end

end