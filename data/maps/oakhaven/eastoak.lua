-- Lua script of map oakhaven/eastoak.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  map:cloud_overlay()
  if game:get_value("eastoak_barrow_door_state") then barrow_door_wall:set_enabled(false) end
end)

local barrow_primed = false
for opener in map:get_entities("barrow_opener") do
function opener:on_interaction()
  if not barrow_primed then
    sol.audio.play_sound"switch"
    map:get_camera():shake()
    barrow_primed = true
    opener:remove()
  else
    map:focus_on(map:get_camera(), barrow_door, function()
  --    map:get_camera():shake()
      map:open_doors("barrow_door")
      barrow_door_wall:set_enabled(false)
      sol.audio.play_sound"secret"
    end, 1200)
  end
end
end


function trapdoor_rune:on_interaction()
  sol.audio.play_sound"switch"
  sol.audio.play_sound"bush"
  grass_trap_door:set_enabled(false)
  holefall_tele:set_enabled(true)
end