local map = ...
local game = map:get_game()
local black = sol.surface.create()
black:fill_color{0,0,0}
black:set_opacity(0)

function map:on_started()
    game:get_hud():set_enabled(false)
    game:set_pause_allowed(false)
end

function map:on_opening_transition_finished()
  --Tilia
  hero:set_walking_speed(85)
  hero:walk"66444444666666777666"
  sol.timer.start(map,1800, function() hero:freeze() end)
  --Mallow
  local mm = sol.movement.create"path"
  mm:set_path{6,6,4,4,4,4,4,4,4,4,6,6,6,6,6,6,6,6}
  mm:set_speed(70)
  mm:start(mallow)
  --Hazel
  local hm = sol.movement.create"path"
  hm:set_path{0,0,0,2,2,2,2,2,2}
  hm:set_speed(35)
  hm:start(hazel, function()
    game:start_dialog("_endgame.oakhaven_1", function()
      black:fade_in(60, function()
        hero:teleport("dummy_cutscene/limestone_scroll")
      end)
    end)
  end)
end

function map:on_draw(s)
  black:draw(s)
end
