-- Lua script of map Yarrowmouth/hourglass_fort.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
  local thyme_sprite = thyme:get_sprite()
  thyme_sprite:set_animation("stopped")
  if game:get_value("quest_hazel") then
    cutscene_sensor:set_enabled(false)
    thyme:set_enabled(false)
  end
end)


function cutscene_sensor:on_activated()
  cutscene_sensor:set_enabled(false)
  local thyme_sprite = thyme:get_sprite()
  hero:freeze()
  hero:get_sprite():set_animation("walking")
  local m = sol.movement.create("path")
  m:set_path{2,2,2,2,2,2,2,2,2,2,2,2}
  m:set_speed(90)
  m:start(hero, function()
    hero:freeze()
    game:start_dialog("_yarrowmouth.npcs.hourglass_encounter.1", function()
      sol.timer.start(map, 800, function()
        thyme_sprite:set_direction(3)
        sol.timer.start(map, 800, function()
          game:start_dialog("_yarrowmouth.npcs.hourglass_encounter.2", function() map:cutscene_2() end)
        end)
      end)
    end)
  end)
end

function map:cutscene_2()
  local thyme_sprite = thyme:get_sprite()
  sol.audio.play_sound("thunk1")
  gavrillo:set_enabled(true)
  sol.timer.start(map,600, function() hero:walk("444422226") end)
  sol.timer.start(map, 1600, function() hero:freeze() end)
  local m = sol.movement.create("path")
  m:set_path{2,2,2,2,2,2,2,2,2,2,2,2,2,2}
  m:set_speed(75)
  m:start(gavrillo, function()
    game:start_dialog("_yarrowmouth.npcs.hourglass_encounter.3", function()
      local x, y, l = gavrillo:get_position()
      map:create_custom_entity({
        direction = 1,x = x, y = y, layer = l, width = 32, height = 32,
        model = "ephereral_effect", sprite = "enemies/misc/sword_slash"
      })
      sol.audio.play_sound("sword2")
      local m2 = sol.movement.create("straight")
      m2:set_max_distance(16)
      m2:set_speed(200)
      m2:set_angle(math.pi / 2)
      m2:start(thyme, function() thyme_sprite:set_animation("unconscious") end)
      thyme_sprite:set_animation("unconscious")
      local gavrillo_sprite = gavrillo:get_sprite()
      gavrillo_sprite:set_animation("attack", function()
        gavrillo_sprite:set_animation("stopped")
        thyme_sprite:set_animation("unconscious")
        thyme:remove_sprite()
        thyme:create_sprite("enemies/enemy_killed")
        sol.audio.play_sound("enemy_killed")
        sol.timer.start(map, 1000, function()
          local m3 = sol.movement.create("path")
          m3:set_path{6,6,6}
          m3:start(gavrillo, function()
            game:start_dialog("_yarrowmouth.npcs.hourglass_encounter.4", function()
              m3:set_path{6,6,6,6,6,6,6,6,6,6,6}
              m3:start(gavrillo, function()
                gavrillo:set_enabled(false)
                game:start_dialog("_yarrowmouth.npcs.hourglass_encounter.5", function()
                  thyme:remove()
                  game:set_value("quest_hourglass_fort", 3) --quest log
                  game:set_value("quest_hazel", 0) --quest log
                  hero:unfreeze()
                end)
              end)
            end)
          end)
        end)
      end)
    end)
  end)
end