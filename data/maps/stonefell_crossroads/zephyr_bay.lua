-- Lua script of map stonefell_crossroads/zephyr_bay.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  map:cloud_overlay()
  if not game:get_value("yarrowmouth_lighthouse_activated") then
    light_1:set_enabled(false)
    light_2:set_enabled(false)
    light_3:set_enabled(false)
  end

  if game:get_value("quest_lighthouses") and game:get_value("quest_lighthouses") >= 1 and game:get_value("quest_lighthouses") < 3 then
    fog:set_enabled(true)
    ghost_ship:set_enabled(true)
    ghost_ship_sensor:set_enabled(true)
    sol.audio.stop_music()
  end
end)

--ghost ship
function ghost_ship_sensor:on_activated()
  game:start_dialog("_yarrowmouth.ghost_ship.board_question", function(answer)
    if answer == 2 then
      hero:teleport("Yarrowmouth/caves/ghost_ship", "from_outside")
    end
  end)
end
