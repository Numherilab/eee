-- Lua script of map Yarrowmouth/foothills.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  require("scripts/fx/sound_atmosphere_manager"):start_atmosphere(map, "birds")

--footprints
  if game:get_value("puzzlewood_footprints_visible") == true then
    for prints in map:get_entities("footprints") do
      prints:set_enabled(true)
    end
  else
    for prints in map:get_entities("footprints") do
      prints:set_enabled(false)
    end
  end
  

end)