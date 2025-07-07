-- Lua script of map stonefell_crossroads/lotus_shoal.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  map:cloud_overlay()
  if game:get_value("boomerang_fort_boss_killed") then
    boomerang_boss:set_enabled(false)
    map:set_doors_open("fort_boss_door")
    lenda:set_enabled(false)
  end
  if game:get_value"lotus_shoal_kappa_beast" then
    bait_monster:remove()
    bait_vase:remove()
  end
  if game:get_item("boomerang"):get_variant() == 2 then
    boomerang_chest:set_treasure("coral_ore", 1)
  end
end)


----Lenda----
function lenda:on_interaction()
  if not game:get_value("quest_shoal_pirate_fort") then
    game:start_dialog("_sycamore_ferry.npcs.lenda.1", function()
      game:set_value("quest_shoal_pirate_fort", 0)
      hero:start_treasure("key_shoal_pirate_fort")
      game:get_item("key_shoal_pirate_fort"):set_variant(1)
    end)
  elseif game:get_value("quest_shoal_pirate_fort") == 0 then
    game:start_dialog("_sycamore_ferry.npcs.lenda.2")
  end
end


----Fort------
function pirate_door:on_interaction()
  if game:has_item("key_shoal_pirate_fort") then
    sol.audio.play_sound"door_unlocked"
    pirate_door:remove()
  else
    game:start_dialog("_game.locked_door")
  end
end

function fort_switch_1:on_activated()
  sol.audio.play_sound("switch")
  map:focus_on(map:get_camera(), fort_door_1, function()
    map:open_doors("fort_door_1")
  end)
end

function fort_switch_2:on_activated()
  sol.audio.play_sound("switch")
  map:focus_on(map:get_camera(), fort_door_2, function()
    map:open_doors("fort_door_2")
  end)
end

function boomerang_boss:on_dead()
  game:set_value("boomerang_fort_boss_killed", true)
  game:set_value("quest_shoal_pirate_fort", 1)
  map:open_doors("fort_boss_door")
  sol.audio.play_sound"switch"
  sol.audio.play_sound"secret"
end

function pirate_note:on_interaction()
  game:start_dialog("_goatshead.observations.coast_notes_1", function()
    if not game.world_map:get_visible("world_map_landmass_ballast_island") then
        game:start_dialog"_goatshead.observations.coast_notes_1-2"
        game.world_map:set_map_visible("ballast_harbor/ballast_harbor")
    end
  end)
end


----Shoal Beast
function bait_vase:on_lifting()
  sol.timer.start(1200, function()
    hero:unfreeze()
    if map:has_entity("bait_monster") == true then bait_monster:set_enabled(true) end
    sol.audio.play_sound("monster_roar_1")
  end)
end

function bait_monster:on_dead()
  game:set_value("lotus_shoal_kappa_beast", true)
  if game:get_value("danley_convo_counter") == nil then
    game:set_value("danley_convo_counter", "special")
  else
    game:set_value("danley_convo_counter", 2)
    game:set_value("quest_crabhook_shoal_monster", 3) --quest log
  end
end
