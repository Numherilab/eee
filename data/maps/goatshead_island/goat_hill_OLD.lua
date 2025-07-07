-- Lua script of map goatshead_island/goat_hill.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()
local music

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  local random_walk = sol.movement.create("random_path")
  random_walk:set_speed(15)
  random_walk:set_ignore_obstacles(false)
  random_walk:start(goat_1)

  local random_walk2 = sol.movement.create("random_path")
  random_walk2:set_speed(10)
  random_walk2:set_ignore_obstacles(false)
  random_walk2:start(goat_2)

  local random_walk3 = sol.movement.create("random_path")
  random_walk3:set_speed(12)
  random_walk3:set_ignore_obstacles(false)
  random_walk3:start(goat_3)

  local random_walk4 = sol.movement.create("random_path")
  random_walk4:set_speed(19)
  random_walk4:set_ignore_obstacles(false)
  random_walk4:start(goat_4)

  local random_walk5 = sol.movement.create("random_path")
  random_walk5:set_speed(4)
  random_walk5:set_ignore_obstacles(false)
  random_walk5:start(abberforth)

end


function guard_3:on_interaction()
  if game:get_value("barbell_brutes_defeated") ~= true then
    game:start_dialog("_goatshead.npcs.guards.7")
  else
    game:start_dialog("_goatshead.npcs.guards.post_defeat.1")
  end
end

function guard_4:on_interaction()
  if game:get_value("barbell_brutes_defeated") ~= true then
    game:start_dialog("_goatshead.npcs.guards.6")
  else
    game:start_dialog("_goatshead.npcs.guards.post_defeat.1")
  end
end


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
    sol.audio.play_music(music)
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