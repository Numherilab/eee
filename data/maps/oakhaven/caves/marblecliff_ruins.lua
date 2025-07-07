-- Lua script of map oakhaven/caves/marblecliff_ruins.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(2)
  sol.menu.start(map, lighting_effects)
end)

function f1_switch:on_activated()
  map:open_doors("f1_door")
end

function f2_switch:on_activated()
  map:open_doors("f2_door")
end

function f3_switch:on_activated()
  map:open_doors("f3_door")
end

function spider:on_dead()
  map:open_doors("ruins_door")
end

function elixer_spirit:on_interaction()
  if game:get_value("spoken_with_marblecliff_elixer_spirit") == true then
    game:start_dialog("_yarrowmouth.npcs.elixer_spirit.2")
  else
    game:start_dialog("_yarrowmouth.npcs.elixer_spirit.1", function() sol.audio.play_sound("elixer_upgrade") end)
    game:set_value("elixer_restoration_level", game:get_value("elixer_restoration_level")+6)
    game:set_value("spoken_with_marblecliff_elixer_spirit", true)
  end
end