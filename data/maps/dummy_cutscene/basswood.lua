-- Lua script of map dummy_cutscene/basswood.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local black = sol.surface.create()
black:fill_color{0,0,0}
black:set_opacity(0)

function map:on_started()
  game:set_pause_allowed(false)
  game:get_hud():set_enabled(false)
  hero:set_visible(false)
end

function map:on_opening_transition_finished()
  hero:freeze()
  local m = sol.movement.create"path"
  m:set_path{2,2}
  m:start(mallow, function()
    sol.timer.start(map, 200, function()
      game:start_dialog("_endgame.basswood_1", function()
        mallow:get_sprite():set_animation"hug_open"
        m:set_path{6,6,6,6,6}
        m:set_speed(50)
        m:start(linden,function() mallow:get_sprite():set_animation"hug_closed" end)
        sol.timer.start(map, 500, function()
          black:fade_in(60, function()
            hero:teleport("dummy_cutscene/lily_pirate")
          end)
        end)
      end)
    end)
  end)
end

function map:on_draw(s)
  black:draw(s)
end
