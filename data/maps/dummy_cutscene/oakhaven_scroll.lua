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
  local m = sol.movement.create"straight"
  m:set_angle(math.pi / 2)
  m:set_speed(80)
  m:start(hero)
  sol.timer.start(map, 3000, function()
    sol.timer.start(map, 500, function()
      black:fade_in(60, function()
        hero:set_visible(true)
        hero:teleport("dummy_cutscene/hazel_oakhaven")
      end)
    end)
  end)

end

function map:on_draw(s)
  black:draw(s)
end