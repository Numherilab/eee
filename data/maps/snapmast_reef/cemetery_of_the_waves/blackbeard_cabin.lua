-- Lua script of map snapmast_reef/cemetery_of_the_waves/blackbeard_cabin.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
  require("scripts/fx/sound_atmosphere_manager"):start_atmosphere(map, "rain_inside")
  map:set_doors_open("boss_doors")
  if game:get_value("assassinbeard_killed") then
    boss_sensor:set_enabled(false)
  else
    assassinbeard:set_enabled(true)
  end
end)



function boss_sensor:on_activated()
  boss_wall:set_enabled(false)
  map:close_doors("boss_doors")
  game:start_dialog("_snapmast.cemetery_of_the_waves.assassinbeard", function()
    sol.audio.play_music"boss_battle"
    boss_sensor:set_enabled(false)
  end)
end

function assassinbeard:on_dead()
  map:fade_in_music()
  game:set_value("assassinbeard_killed", true)
  map:open_doors("boss_doors")
  map:create_pickable({
    layer = 0, x = 208, y = 592, treasure_name = "health_upgrade",
  })
  for cannon in map:get_entities("barrel_cannon") do
    cannon:remove_life(200)
  end
end

function first_mate:on_interaction()
  if game:get_value("quest_snapmast") ~= 3 then
    game:start_dialog("_snapmast.cemetery_of_the_waves.first_mate.1", function()
      hero:start_treasure("fast_travel_chart_isle_of_storms", 1, nil, function()
        game:set_value("quest_snapmast", 3)
        game:set_value("quest_isle_of_storms", 0)
        hero:teleport("snapmast_reef/drowned_village", "from_shipwreck")
      end)
    end)
  else
    game:start_dialog("_snapmast.cemetery_of_the_waves.first_mate.2")
  end
end