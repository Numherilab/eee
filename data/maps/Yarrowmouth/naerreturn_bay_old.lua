-- Lua script of map Yarrowmouth/naerreturn_bay.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  if game:get_value("rohit_dialog_counter") ~= nil and game:get_value("rohit_dialog_counter") >= 2 then
    for entity in map:get_entities("mushroom_golem") do
      entity:set_enabled(false)
    end
  end

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

function trap_sensor:on_activated()
  if game:get_value("rohit_dialog_counter") < 2 then
    map:close_doors("gate")
    trap_you_in_ambush_wall:set_enabled(true)
    game:start_dialog("_yarrowmouth.observations.ambush_2")
  end
end

for golem in map:get_entities("mushroom_golem") do
  function golem:on_dead()
    if map:get_entities_count("mushroom_golem") == 0 then
      game:start_dialog("_yarrowmouth.observations.mushroom_spot.1", function()
        trap_you_in_ambush_wall:set_enabled(false)
        game:set_value("quest_briarwood_mushrooms", 1) --quest log
        game:set_value("rohit_dialog_counter", 2)
        game:set_value("puzzlewood_footprints_visible", true)
        map:open_doors("gate")
      end)
    end
  end
end


--ghost ship
function ghost_ship_sensor:on_activated()
  game:start_dialog("_yarrowmouth.ghost_ship.board_question", function(answer)
    if answer == 2 then
      hero:teleport("Yarrowmouth/caves/ghost_ship", "from_outside")
    end
  end)
end