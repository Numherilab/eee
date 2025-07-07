-- Lua script of map oakhaven/interiors/monastery.
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
  lighting_effects:set_darkness_level(1)
  sol.menu.start(map, lighting_effects)

  if game:get_value("quest_haunted_monastery") then
    map:set_doors_open("gate")
  end

  if game:get_value("quest_haunted_monastery") and game:get_value("quest_haunted_monastery") > 0 then
    map:set_doors_open("boss_door")
  end
end)


--Monk
function monk:on_interaction()
  if not game:get_value("quest_haunted_monastery") then
    game:start_dialog("_oakhaven.npcs.monastery.monk.1", function()
      game:set_value("quest_haunted_monastery", 0)
      map:open_doors("gate")
    end)

  elseif game:get_value("quest_haunted_monastery") == 0 then
    game:start_dialog("_oakhaven.npcs.monastery.monk.2")

  elseif game:get_value("quest_haunted_monastery") == 1 then
     game:start_dialog("_oakhaven.npcs.monastery.monk.3", function()
      map:get_hero():start_treasure("bread", 2)
      game:set_value("quest_haunted_monastery", 2)
    end)

  elseif game:get_value("quest_haunted_monastery") == 2 then
    game:start_dialog("_oakhaven.npcs.monastery.monk.4")

  end
end


function hidden_book:on_interaction()
  game:start_dialog("_oakhaven.observations.monastery.hidden_book1", function(answer)
    if answer == 2 then
      game:start_dialog("_oakhaven.observations.monastery.hidden_book2")
    end
  end)
end

function hidden_book_2:on_interaction()
  game:start_dialog("_oakhaven.observations.monastery.hidden_book1", function(answer)
    if answer == 2 then
      game:start_dialog("_oakhaven.observations.monastery.hidden_book3")
    end
  end)
end

function spring_door_switch:on_activated()
  map:open_doors"spring_door"
end

function reset_storage_block_sensor:on_activated()
  for b in map:get_entities"storage_block" do
    b:reset()
  end
end

function boss_sensor:on_activated()
  if game:get_value("quest_haunted_monastery") and game:get_value("quest_haunted_monastery") < 1 then
    boss:set_enabled(true)
    sol.audio.play_sound("monster_scream")
    boss_sensor:set_enabled(false)
  end
end

function boss:on_dead()
  game:set_value("quest_haunted_monastery", 1)
  map:open_doors("boss_door")
end
