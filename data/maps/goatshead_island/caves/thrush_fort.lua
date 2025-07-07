-- Lua script of map goatshead_island/caves/thrush_fort.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()

map:register_event("on_started", function()
  map:set_doors_open("door_1")
  map:set_doors_open("door_3")
  if game:has_item("thunder_charm") then
    map:set_doors_open("door")
    boss_sensor:set_enabled(false)
    trap_2_sensor:set_enabled(false)
    boss:set_enabled(false)
  end
  if game:get_value("quest_heron_well") == 0 then
    game:set_value("quest_heron_well", 1)
  end

end)

function boss_sensor:on_activated()
  boss_wall:set_enabled(false)
  map:close_doors("door_1")
  boss_sensor:set_enabled(false)
end

function boss:on_dead()
  map:open_doors("door_2")
  for enemy in map:get_entities_by_type("enemy") do
    enemy:remove()
  end
  if game:get_value("quest_heron_well") == 1 then
    game:set_value("quest_heron_well", 2)
  end
end


function trap_2_sensor:on_activated()
  map:close_doors("door_3")
  trap_2_sensor:set_enabled(false)
end

function unsparkle_sensor:on_activated()
  for sparkle in map:get_entities("sparkle") do
    sparkle:set_enabled(false)
  end
end

function all_door_switch:on_activated()
  game:set_value("quest_heron_well", 3)
  if not game:get_value"quest_heron_doors" then
    game:set_value("quest_heron_doors", 0)
    game.objectives:set_alternate("heron_doors_alt", "quest.side.heron_doors")
  end
  map:open_doors("door")
end
