-- Lua script of map oakhaven/caves/saltpeter_mines.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(2)
  sol.menu.start(map, lighting_effects)

  map:set_doors_open("boss_door")

  if game:get_value("quest_bomb_shop") and game:get_value("quest_bomb_shop") >= 3 then
    boss:set_enabled(false)
  end

end)

function boss:on_dead()
  game:set_value("quest_bomb_shop", 3)
end
