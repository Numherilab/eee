-- Lua script of map stonefell_crossroads/crow_road.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

function arrow_switch:on_activated()
  sol.audio.play_sound"switch"
  map:focus_on(map:get_camera(), gate_door, function()
    map:open_doors("gate_door")
  end)
end
