local menu = {}

menu.bg = sol.surface.create"menus/splash_screens/nordcurrent.png"
local FADE_IN_TIME = 34
local FADE_OUT_TIME = 20

function menu:on_started()
  menu.bg:fade_in(FADE_IN_TIME)

  sol.timer.start(self, 2400, function()
    menu.bg:fade_out(FADE_OUT_TIME)
  end)

  sol.timer.start(self, 3400, function()
    sol.menu.stop(self)
  end)
end

function menu:on_draw(dst)
  menu.bg:draw(dst)
end

return menu