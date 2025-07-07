local map = ...
local game = map:get_game()
local black = sol.surface.create()
black:fill_color{0,0,0}
black:set_opacity(0)


function map:on_started()
  brutus:get_sprite():set_animation"stopped"
  hero:set_visible(false)
  game:get_hud():set_enabled(false)
  game:set_pause_allowed(false)
end

function map:on_opening_transition_finished()
  hero:freeze()
  local m2 = sol.movement.create"path"
  m2:set_path{4,3,3,4}
  sol.timer.start(map, 1500, function() m2:start(hornigold) end)

  local m = sol.movement.create"path"
  m:set_path{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
  m:set_speed(60)
  m:start(lily, function()
    game:start_dialog("_endgame.lily", function()
      sol.timer.start(map, 1000, function()
        game:start_dialog("_endgame.lily_2", function()
          black:fade_in(60, function()
            hero:teleport("dummy_cutscene/limestone", "cut_dest")
          end)
        end)
      end)
    end)
  end)
end

function map:on_draw(s)
  black:draw(s)
end
