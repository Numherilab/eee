local map = ...
local game = map:get_game()
local black = sol.surface.create()
black:fill_color{0,0,0}
black:set_opacity(0)


function map:on_started()
  hero:set_visible(false)
  game:get_hud():set_enabled(false)
  game:set_pause_allowed(false)
  local m = sol.movement.create"path"
  m:set_path{2,2,0,0,0,0,0,0,2,2,2,2,2,2,2,2,2,0,0,2,2,2,2,2,1,2,2}
  m:set_speed(45)
  m:set_ignore_obstacles()
  m:start(hazel, function()
    sol.timer.start(map, 10, function()
      m:set_path{2,2,2,2,2,2,2,2,2,2,2,2}
    end)
  end)

  local m2 = sol.movement.create"path"
  m2:set_path{0,0,0,0,1,1,1,1,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2,2,2,2,2,0,0,2,2,2,2,2,1,2,2}
  m2:set_speed(45)
  m2:set_ignore_obstacles()
  m2:start(tilia_dummy)


end


function map:on_opening_transition_finished()
  hero:freeze()

  local cm = sol.movement.create"straight"
  cm:set_angle(1.2)
  cm:set_ignore_obstacles()
  cm:set_speed(80)
  cm:set_max_distance(4500)
  cm:start(map:get_camera(), function()
  end)

  sol.timer.start(map, 6000, function()
    black:fade_in(180, function()
      sol.menu.start(sol.main, require("scripts/menus/credits2"))
    end)
  end)

  sol.timer.start(map, 3500, function()
    local title_card = require"scripts/menus/title_card"
    sol.main.get_game():get_hud():set_enabled(false)
    sol.menu.start(map, title_card)
    sol.timer.start(map, 9000, function() title_card:fade_out() end)
  end)
end


function map:on_draw(s)
  black:draw(s)
end
