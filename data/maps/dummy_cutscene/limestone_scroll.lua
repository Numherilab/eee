local map = ...
local game = map:get_game()
local black = sol.surface.create()
black:fill_color{0,0,0}
black:set_opacity(0)

function map:on_started()
  game:set_pause_allowed(false)
  game:get_hud():set_enabled(false)
  hero:set_visible(false)
  invisible_stairs:set_visible(false)
end

function map:on_opening_transition_finished()
  hero:freeze()
  hero:set_layer(map:get_max_layer())
  local m = sol.movement.create"straight"
  m:set_angle(math.pi / 6 * 11)
  m:set_speed(100)
  m:set_ignore_obstacles(true)
  m:start(map:get_camera())
  sol.timer.start(map, 7000, function()
    sol.timer.start(map, 500, function()
      black:fade_in(60, function()
        hero:set_visible(true)
        hero:teleport("dummy_cutscene/basswood")
      end)
    end)
  end)

end

function map:on_draw(s)
  black:draw(s)
end