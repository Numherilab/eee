-- Lua script of map goatshead_island/caves/brickabranch_shrine.
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
  lighting_effects:set_darkness_level(3)
  sol.menu.start(map, lighting_effects)

  boss:set_damage(3)
end)

function boss:on_dead()
  map:open_doors("boss_door")
end

function seen_lack_of_statue_sensor:on_activated()
  if game:get_value("quest_dusit") < 2 then
    game:set_value("quest_dusit", 2)
  end
end