-- Lua script of map new_limestone/tavern_upstairs.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = game:get_hero()
local sprite = hero:get_sprite()


map:register_event("on_started", function()
  game:set_starting_location("new_limestone/tavern_upstairs", "respawn_point")
  hero:set_walking_speed(98) --can't do this in initial game because there is no hero
  game.world_map:set_map_visible("new_limestone/new_limestone_island")
  if not game:get_value("waking_up_beginning_of_game_cutscene") then
    hero:freeze()
    sprite:set_animation("asleep")
  end
end)

map:register_event("on_opening_transition_finished", function()
  if not game:get_value("waking_up_beginning_of_game_cutscene") then
    hero:freeze()
    sprite:set_animation("asleep")
    game:set_value("waking_up_beginning_of_game_cutscene", true)
    sol.timer.start(map, 500, function()
      sprite:set_animation("waking_up", function()
        sprite:set_animation("stopped")
        hero:start_jumping(0, 24, true)
        sol.timer.start(map, 500, function()
          sol.main.get_game():get_hud():set_enabled(true)
          game:set_respawn_point()
          game:set_pause_allowed(true)
          hero:unfreeze()

        end)
      end)
    end)

  end
end)

--move
--action
--pause

--Don't need to baby the player and teach them how to move, they'll figure it out.
--Also they likely had to use the arrow keys to start a new game on the menu
--[[
function controls_sensor:on_activated()
  if not game:get_value("limestone_controls_explanation_move") then
    game:get_dialog_box():set_style("empty")
    game:start_dialog("_game.controls.move", function()
      game:get_dialog_box():set_style("box")
      game:set_value("limestone_controls_explanation_move", true)
    end)
  end
end
--]]

function controls_sensor_2:on_activated()
  if sol.main.get_os() == "Nintendo Switch" then return end --skip if on switch. You know the buttons.
  if not game:get_value("limestone_controls_explanation_action") then
    game:get_dialog_box():set_style("empty")
    game:start_dialog("_game.controls.action", function()
      game:get_dialog_box():set_style("box")
      game:set_value("limestone_controls_explanation_action", true)
    end)
  end
end


