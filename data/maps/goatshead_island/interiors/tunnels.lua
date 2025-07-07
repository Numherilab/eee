-- Lua script of map goatshead_island/interiors/tunnels.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(2)
  sol.menu.start(map, lighting_effects)

  --initialize adventurers if quest accepted
  if game:get_value("goatshead_tunnels_accepted") ~= true then
    adventurer_1:set_enabled(false)
    adventurer_2:set_enabled(false)
  end

end)

function adventurer_1:on_interaction()
  --if quest complete
  if game:get_value("goat_tunnel_quest_complete") == true then
    game:start_dialog("_goatshead.npcs.tavern_people.adventurers.9")
  else --if quest isn't complete
    if game:get_value("goat_tunnel_spider_defeated") ~= nil then
      game:start_dialog("_goatshead.npcs.tavern_people.adventurers.8")
      game:set_value("goat_tunnel_quest_complete", true)
      game:set_value("quest_goatshead_secret_tunnels", 3)
    else
      game:start_dialog("_goatshead.npcs.tavern_people.adventurers.7", function()
        map:open_doors("tunnel_door")
        game:set_value("quest_goatshead_secret_tunnels", 1)
      end)

    end
  end
end

function boss_sensor:on_activated()
  boss_wall:set_enabled(false)
end

if map:has_entity("goat_tunnel_spider") then
  function goat_tunnel_spider:on_dead()
    game:set_value("quest_goatshead_secret_tunnels", 2)
  end
end
