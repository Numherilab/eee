-- Lua script of map goatshead_island/poplar_coast.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  if game:get_value("boomerang_fort_boss_killed") then
    boomerang_boss:set_enabled(false)
    map:set_doors_open("fort_boss_door")
  end
  bait_monster:set_enabled(false)

end)



function bait_vase:on_lifting()
--  hero:freeze()
  sol.timer.start(1200, function()
    hero:unfreeze()
    if map:has_entity("bait_monster") == true then bait_monster:set_enabled(true) end
    sol.audio.play_sound("monster_roar_1")
  end)
end

function bait_monster:on_dead()
  if game:get_value("danley_convo_counter") == nil then
    game:set_value("danley_convo_counter", "special")
  else
    game:set_value("danley_convo_counter", 2)
    game:set_value("quest_crabhook_shoal_monster", 3) --quest log
  end
end



----Fort------
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
  map:open_doors("fort_boss_door")
end
