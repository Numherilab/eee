-- Lua script of map snapmast_reef/cemetery_of_the_waves/shipwreck_chain.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
  require("scripts/fx/sound_atmosphere_manager"):start_atmosphere(map, "rain_inside")

  if game:get_value("quest_snapmast") == 1 then game:set_value("quest_snapmast", 2) end

end)


-------switches
function b7_switch:on_activated()
  sol.audio.play_sound("switch")
  map:focus_on(map:get_camera(), b7_door, function() map:open_doors("b7_door") end)
end

function d4_door_switch:on_activated()
  sol.audio.play_sound("switch")
  map:focus_on(map:get_camera(), d4_door, function() map:open_doors("d4_door") end)
end

function c5_door_switch:on_activated()
  sol.audio.play_sound("switch")
  map:focus_on(map:get_camera(), c5_door, function() map:open_doors("c5_door") end)
end

function d5_door_switch:on_activated()
  sol.audio.play_sound("switch")
  map:focus_on(map:get_camera(), d5_door, function() map:open_doors("d5_door") end)
end

function b1_door_switch:on_activated()
  sol.audio.play_sound("switch")
  map:focus_on(map:get_camera(), b1_door, function() map:open_doors("b1_door") end)
end

function door_a1_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("door_a1")
end


--------enemies
for enemy in map:get_entities("a5_door_enemy") do
function enemy:on_dead()
  if not map:has_entities("a5_door_enemy") then
    map:open_doors("door_a5")
  end
end
end

function miniboss:on_dead()
    map:open_doors("miniboss_door")
end



function chest_mimic:on_dead()
  if not cemetery_of_the_waves_chest_d1_state then
    sol.audio.play_sound("secret")
    coral_ore_chest:set_enabled(true)
    map:create_poof(coral_ore_chest:get_position())
  end
end