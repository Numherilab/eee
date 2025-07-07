-- Lua script of map demo_1/bow_island_3.
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

function sign:on_interaction()
game:set_value("hemlock_ruins_travel_unlocked", true)

  if game:get_value("east_verne_travel_unlocked") ~= true then
  game:start_dialog("demo_1.signs.bow_island.no_travel")

  else
    game:start_dialog("demo_1.signs.bow_island.travel", function(answer)
      if answer == 3 then
      hero:teleport("demo_1/bow_peninsula_1", "from_hemlock_ruins")
      end -- if answer is yes conditional end
    end) -- dialogue question function end
  end --conditional for which question to ask end 
end --function end