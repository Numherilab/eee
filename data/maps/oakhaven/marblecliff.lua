-- Lua script of map oakhaven/marblecliff.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  map:cloud_overlay("fog/clouds_2.png")
  if game:get_value("marblecliff_secret_tunnel_opened") then
    rock_door:set_enabled(false)
    hidden_tunnel_npc:set_enabled(false)
  end
end)


function hidden_tunnel_npc:on_interaction()
  if game:get_value("burglars_saved") and not game:get_value("marblecliff_secret_tunnel_opened") then
    game:set_value("marblecliff_secret_tunnel_opened", true)
    sol.audio.play_sound("secret")
    hidden_tunnel_npc:set_enabled(false)
    rock_door:set_enabled(false)
  else
    game:start_dialog"_game.too_heavy"
  end
end

function clue_sensor:on_activated()
  if game:get_value("marblecliff_palace_tunnel_clue_reminder") == nil and game:get_value("burglars_saved") == true then
    game:start_dialog("_oakhaven.observations.clues.marblecliff_palace_tunnel")
    game:set_value("marblecliff_palace_tunnel_clue_reminder", true)
  end
end

function ruins_switch:on_activated()
  sol.audio.play_sound("switch")
  map:focus_on(map:get_camera(), ruins_door_1, function() map:open_doors("ruins_door") end)
end
