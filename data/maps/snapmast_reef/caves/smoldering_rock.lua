-- Lua script of map snapmast_reef/caves/smoldering_rock.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
  local x, y, l = emblem:get_position()
  local zapper = game:get_item("thunder_charm")
  if not game:get_value("smoldering_rock_seabird_upgrade_received") then
    map:create_pickable({
      x = x + 8, y = y + 16, layer = l,
      treasure_name = "thunder_charm", treasure_variant = zapper:get_variant() + 1,
      treasure_savegame_variable = "smoldering_rock_seabird_upgrade_received",
    })
  end

  if game:get_value("smoldering_rock_found_fire_arrows") then
    fire_arrow_boss:set_enabled(false)
  end

end)

function heron_door_sensor:on_activated()
  if not game:has_item("heron_door_snapmast") then
    game:get_item("heron_door_snapmast"):set_variant(1)
    game:set_value("found_heron_door_snapmast", 1) --TODO quest log issue #76
    game.objectives:force_update() --TODO quest log issue #70
  end
end

function ring_switch_a:on_activated()
  map:open_doors("ring_a_door")
  sol.audio.play_sound"switch"
  sol.audio.play_sound"secret"
  map:get_camera():shake()
end

function ring_switch_b:on_activated()
  map:open_doors("ring_b_door")
  sol.audio.play_sound"switch"
  sol.audio.play_sound"secret"
  map:get_camera():shake()
end


function fire_arrow_boss:on_dead()
  map:open_doors("fire_arrow_door")
end

function seabird_boss:on_dead()
  map:open_doors("second_boss_door")
end
