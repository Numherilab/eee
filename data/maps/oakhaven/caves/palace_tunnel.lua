-- Lua script of map oakhaven/caves/palace_tunnel.
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

  if not game:get_value("quest_hazel") or game:get_value("quest_hazel") ~= 6 then
    map:open_doors"secret_tunnel_door"
  end

end)