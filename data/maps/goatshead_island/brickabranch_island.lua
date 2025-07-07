-- Lua script of map goatshead_island/brickabranch_island.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local switches_pressed

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
  require("scripts/fx/sound_atmosphere_manager"):start_atmosphere(map, "rain")
  local world = map:get_world()
  game:set_world_rain_mode(world, "rain")

  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(2)
  sol.menu.start(map, lighting_effects)

  switches_pressed = 0

  sol.achievements.unlock("ach_brickenbranch")

  if game:get_value("quest_dusit") == 0 then game:set_value("quest_dusit", 1) end

end)

for switch in map:get_entities("door_switch") do
  function switch:on_activated()
    sol.audio.play_sound("switch")
    switches_pressed = switches_pressed + 1
    if switches_pressed >= 3 then
      map:focus_on(map:get_camera(), shrine_door, function()
        map:open_doors("shrine_door")
      end)
    end
  end
end

function boat_sensor:on_activated()
  game:start_dialog("_goatshead.npcs.crabhook.dusit.go_to_crabhook", function(answer)
    if answer == 3 then
      game:get_hero():teleport("goatshead_island/crabhook_village", "from_brickenbranch")
    end
  end)
end