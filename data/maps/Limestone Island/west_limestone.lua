-- Lua script of map Limestone Island/west_limestone.
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



--Pirate
function pirate_2:on_interaction()
  if game:get_value("talked_to_wally") == 1 then
    game:start_dialog("_limestone_island.npcs.fishing_pirate.2")
  else
    game:start_dialog("_limestone_island.npcs.fishing_pirate.1")
  end
end


--Signs
--South to Sometimes Cape
function sign_1:on_interaction()
game:set_value("west_limestone_1_travel_unlocked", true)

  if game:get_value("sometimes_cape_travel_unlocked") ~= true then
  game:start_dialog("_signs.limestone.west_limestone_1.no_travel")

  else
    game:start_dialog("_signs.limestone.west_limestone_1.travel", function(answer)
      if answer == 2 then
      hero:teleport("Limestone Island/sometimes_cape", "from_west_limestone")
      end
    end)
  end
end

