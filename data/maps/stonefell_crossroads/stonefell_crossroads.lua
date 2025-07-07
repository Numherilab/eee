-- Lua script of map stonefell_crossroads/stonefell_crossroads.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  map:cloud_overlay()

  if game:get_value("nina_dialog_counter") ~= nil and game:get_value("nina_dialog_counter") >= 3 then
    dream_cannon_guard:set_enabled(false)
  end
  if game:get_value"dream_cannons_defeated" then for pirate in map:get_entities"dream_cannon_pirate" do
    pirate:set_enabled(false)
  end end
end)


function oakstone_switch:on_activated()
  sol.audio.play_sound"switch"
  map:open_doors("oakstone_door")
end

function dream_cannon_switch:on_activated()
  sol.audio.play_sound"switch"
  map:open_doors"dream_cannon_door"
end
