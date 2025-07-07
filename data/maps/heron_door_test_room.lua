-- Lua script of map heron_door_test_room.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = game:get_hero()

local function upgrade_thunder_charm(savegame_variable)
  local zapper = game:get_item("thunder_charm")
  local hero_x, hero_y, hero_layer = hero:get_position()
  map:create_pickable({
    x = hero_x, y = hero_y, layer = hero_layer,
    treasure_name = "thunder_charm", treasure_variant = zapper:get_variant() + 1,
    treasure_savegame_variable = savegame_variable,
  })
end

function door_item_sensor:on_activated()
  if not game:has_item("heron_door_snapmast") then
    game:get_item("heron_door_snapmast"):set_variant(1)
    game:set_value("found_heron_door_snapmast", 1) --TODO quest log issue #76
    game.objectives:force_update() --TODO quest log issue #70
print("you got an item snapmast")
  end
end

function door_item_sensor_2:on_activated()
  if not game:has_item("heron_door_marble_summit") then
    game:get_item("heron_door_marble_summit"):set_variant(1)
    game:set_value("found_heron_door_marble_summit", 1) --TODO quest log issue #76
    game.objectives:force_update() --TODO quest log issue #70
print("you got an item marblecliff")
  end
end

function door_item_sensor_3:on_activated()
  if not game:has_item("heron_door_tern_marsh") then
    game:get_item("heron_door_tern_marsh"):set_variant(1)
    game:set_value("found_heron_door_tern_marsh", 1) --TODO quest log issue #76
    game.objectives:force_update() --TODO quest log issue #70
print("you got an item tern marsh")
  end
end

function door_switch:on_activated()
  print"obtained charm at snapmast"
  upgrade_thunder_charm("smoldering_rock_seabird_upgrade_received")
end

function door_switch_2:on_activated()
  print"obtained charm at marble summit"
  upgrade_thunder_charm("marblecliff_seabird_upgrade_received")
end

function door_switch_3:on_activated()
  print"obtained charm at tern marsh"
  upgrade_thunder_charm("tern_marsh_seabird_upgrade_received")
end

function monk:on_interaction()
  local variant = game:get_item("thunder_charm"):get_variant() or 0
  if variant < 1 then
    game:get_item("thunder_charm"):set_variant(1)
    --game:set_value("possession_thunder_charm", 1)
  print("I gave you the charm")
    game:set_value("quest_heron_doors", 0)
    game.objectives:set_alternate("heron_doors_alt", "quest.side.heron_doors")
  end
end