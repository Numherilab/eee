-- Lua script of map goatshead_island/interiors/rilesdorf_mercantile.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local squid_1
local squid_2
local hero = game:get_hero()

map:register_event("on_started", function()
--enable entities
  if game:get_value("squid_fled") ~= true then
    rilesdorf_2:set_enabled(false)
  else
    rilesdorf:set_enabled(false)
  end

  squid:set_enabled(false)
  ink_spill:set_enabled(false)

--movements
  squid_1 = sol.movement.create("path")
  squid_1:set_path{2,4,4,4,4,4,4,2,2}
  squid_1:set_speed(50)
  squid_1:set_loop(false)
  squid_1:set_ignore_obstacles(true)

  squid_2 = sol.movement.create("path")
  squid_2:set_path{6,0,6,6}
  squid_2:set_speed(65)
  squid_2:set_loop(false)
  squid_2:set_ignore_obstacles(true)


end)

function rilesdorf:on_interaction()
  if game:get_value("phantom_squid_quest_accepted") ~= true then
    game:start_dialog("_goatshead.npcs.rilesdorf.1")
  else
    game:start_dialog("_goatshead.npcs.rilesdorf.2", function()
      map:open_doors("upstairs_door")
    end)
  end
end

function hidden_sensor:on_activated()
  if game:get_value("squid_quest_hidden_sensor_tripped") ~= true then
    game:start_dialog("_goatshead.npcs.phantom_squid.wait_for_him_question", function(answer)
      if answer == 2 then
        hero:freeze()
        sol.timer.start(4000, function()
          game:set_value("squid_quest_hidden_sensor_tripped", true)
          sol.audio.play_sound("breaking_glass")
          broken_window_1:set_enabled()
          squid:set_enabled(true)
          squid_1:start(squid)
          hero:unfreeze()
        end)
      end
    end)
  end
end

function hey_squid_sensor:on_activated()
  if game:get_value("squid_quest_hidden_sensor_tripped") == true then
    if game:get_value("squid_fled") ~= true then
      game:start_dialog("_goatshead.npcs.phantom_squid.1", function()
        ink_spill:set_enabled(true)
        squid_2:start(squid)
        sol.timer.start(600, function()
          sol.audio.play_sound("breaking_glass")
          broken_window_2:set_enabled()
          squid:set_enabled(false)
          ink_spill:set_enabled(false)
          sol.timer.start(1000, function()
            game:start_dialog("_goatshead.npcs.phantom_squid.got_away", function()
              game:set_value("quest_phantom_squid", 1) --quest log, chase squid
            end)
            rilesdorf:set_enabled(false)
            rilesdorf_2:set_enabled(true)
            game:set_value("squid_fled", true)
            game:set_value("goatshead_harbor_footprints_visible", true)
          end)
        end)
      end)
    end
  end
end
