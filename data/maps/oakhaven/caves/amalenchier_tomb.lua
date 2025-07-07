-- Lua script of map oakhaven/caves/amalenchier_tomb.
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
  lighting_effects:set_darkness_level(1)
  sol.menu.start(map, lighting_effects)

  if game:get_value("quest_manna_oaks") >= 6 then
    boss_sensor:set_enabled(false)
    forest_revenant:set_enabled(false)
    boss_blocker:set_enabled(false)
    for entity in map:get_entities("pollutant_blocker") do
      entity:remove()
    end
  end
end)

function boss_sensor:on_activated()
  boss_blocker:set_enabled(false)
  game:start_dialog("_oakhaven.observations.misc.amalenchier_revenant_still_alive", function()
    sol.audio.play_music"boss_battle"
  end)
  boss_sensor:set_enabled(false)
end

function forest_revenant:on_dead()
  for entity in map:get_entities("pollutant_blocker") do
    entity:remove_life(100)
  end
  map:fade_in_music()
  map:get_camera():shake({count = 12, amplitude = 7, speed = 80})
  game:set_value("quest_manna_oaks", 6)
end