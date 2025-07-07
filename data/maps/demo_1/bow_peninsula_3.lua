-- Lua script of map demo_1/bow_peninsula_3.
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

--set the solid ground point at the place the hero enters the map
hero:save_solid_ground()

end

function arrow_guy:on_interaction()
if game:has_item("bow") == true then
  game:start_dialog("demo_1.npcs.arrow_guy.1", function()
  map:create_pickable({
  layer = 0,
  x = 200,
  y = 120,
  treasure_name = "arrow",
  treasure_variant = 2,
  })
  end
  ) --end of start dialog method
else
  game:start_dialog("demo_1.npcs.arrow_guy.2")
end
end