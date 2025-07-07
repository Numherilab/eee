-- Lua script of map goatshead_island/goat_hill.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  if game:get_value("goatshead_lighthouse_activated") == true then
    house_light_1:set_enabled(true)
    house_light_2:set_enabled(true)
    house_light_3:set_enabled(true)
    house_light_4:set_enabled(true)
  end
end)

local function unsummon_heron()
    local x, y, l = heron_ghost:get_position()
    map:create_poof(x, y, l)
    darkness:set_enabled(false)
    ghost_smoke:set_enabled(false)
    heron_ghost:set_enabled(false)
    sol.audio.play_sound("thunder3")
    sol.audio.play_sound("sea_spirit")
    sol.audio.play_sound("summon_in")
    hero:unfreeze()
    sol.audio.play_music("newfashioned_port_burg")
end


local function summon_heron()
    sol.audio.stop_music()
    heron_ghost:set_enabled(true)
    ghost_smoke:set_enabled(true)
    darkness:set_enabled(true)
    heron_ghost:get_sprite():set_ignore_suspend(true)
    ghost_smoke:get_sprite():set_ignore_suspend(true)
    local x, y, l = heron_ghost:get_position()
    map:create_poof(x, y, l)
    sol.audio.play_sound("thunder3")
    sol.audio.play_sound("sea_spirit")
    sol.audio.play_sound("summon_in")
    hero:freeze()
    sol.timer.start(map, 800, function()
      --receive the quest
      if not game:get_value("quest_heron_well") then
        game:start_dialog("_goatshead.npcs.heron_ghost.1", function()
          hero:start_treasure("key_thrush_fort")
          unsummon_heron()
        end)

      --if started quest
      elseif game:get_value("quest_heron_well") == 0 then
        game:start_dialog("_goatshead.npcs.heron_ghost.2", function()
          unsummon_heron()
        end)

      elseif game:get_item("thunder_charm"):get_variant() == 4 then
        game:start_dialog("_goatshead.npcs.heron_ghost.4", function()
          unsummon_heron()
        end)

      elseif game:get_value("quest_heron_well") > 2 then
        game:start_dialog("_goatshead.npcs.heron_ghost.3", function()
          unsummon_heron()
        end)

      end
    end) --end timer
end


function well:on_interaction()
  game:start_dialog("_goatshead.npcs.heron_ghost.well_choice", function(answer)
    if answer == 1 then -- drop a few coins
      game:remove_money(3)
      sol.audio.play_sound("splash")

    elseif answer == 2 then --take a drink
      hero:freeze()
      sol.audio.stop_music()
      sol.audio.play_sound("swim")
      sol.audio.play_sound("drink")
      sol.timer.start(map, 2200, function()
        hero:unfreeze()
        summon_heron()
      end)

    elseif answer == 3 then --spit in the well
      hero:freeze()
      sol.audio.play_sound("spit")
      sol.audio.play_sound("drip")
      sol.timer.start(map, 1000, function()
        hero:unfreeze()
        local x, y, l = hero:get_position()
        local zap = map:create_enemy({x=x,y=y+8,layer=l,direction=0,breed="enemy_weapon"})
        zap:create_sprite("entities/lightning_bolt_attack")
        sol.audio.play_sound("thunder1")
      end)

    elseif answer ==4 then --nothing

    end
  end)

end
