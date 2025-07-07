-- Lua script of map oakhaven/veilwood.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  require("scripts/fx/sound_atmosphere_manager"):start_atmosphere(map, "birds")
  game:set_world_fall_mode(map:get_world(), "fall")
  game:set_fall_leaf_color({240,70,60})

  if game:get_value("quest_manna_oaks") == 0 then manna_oak_twig:set_enabled(true) end
  if game:get_value("amalenchier_tomb_open") then
    amalenchier_tombstone:set_enabled(false)
    tombstone_npc:set_enabled(false)
  end
  if game:get_value("quest_manna_oaks") then
    if game:get_value("quest_manna_oaks") == 6 and game:get_value("quest_manna_oaks") < 8 then lamia:set_enabled(true) end
    if game:get_value("quest_manna_oaks") >= 7 then manna_tree_door:set_enabled(false) end
    if game:get_value("quest_manna_oaks") >= 9 then manna_oak_leaves:set_enabled(true) end
  end
end)



--MANNA OAKS SIDEQUEST----------------------
--tombstone
function tombstone_npc:on_interaction()
  if game:get_value("quest_manna_oaks") ~= 5 then
    game:start_dialog("_oakhaven.observations.misc.amalenchier_grave")
  else
    game:start_dialog("_oakhaven.observations.misc.amalenchier_grave", function()
      forest_revenant:set_enabled(true)
      forest_revenant:set_life(18)
    end)
  end
end
--forest revenant first fight
function forest_revenant:on_dead()
  sol.audio.play_sound("hero_pushes") sol.audio.play_sound("switch_2") sol.audio.play_sound("door_closed")
  map:get_camera():shake({count = 6, amplitude = 4, speed = 80})
  amalenchier_tombstone:set_enabled(false)
  tombstone_npc:set_enabled(false)
  game:set_value("amalenchier_tomb_open", true)
end
--lamia
function lamia:on_interaction()
  if game:get_value("quest_manna_oaks") == 6 then
    game:start_dialog("_oakhaven.npcs.ivystump.lamia.4", function()
      game:set_value("quest_manna_oaks", 7)
      game:set_value("manna_oaks_investigated", 0)
      manna_tree_door:set_enabled(false)
    end)
  else
    game:start_dialog("_oakhaven.npcs.ivystump.lamia.4")
  end
end