local menu = {}

menu.bg = sol.surface.create()
menu.leaf = sol.surface.create"menus/sycamore_leaf.png"
menu.text = sol.text_surface.create{
  horizontal_alignment = "center",
  font = "enter_command",
  font_size = 16,
  text = "Max Mraz",
}
menu.moths = sol.sprite.create"menus/splash_screens/moths"
menu.max_name = sol.sprite.create"menus/splash_screens/maxname"
menu.box = sol.sprite.create"menus/splash_screens/mothbox"

local X, Y = 208, 120 --center of elements
local FADE_IN_TIME = 34
local FADE_OUT_TIME = 20

function menu:on_started()
--  menu.leaf:draw(menu.bg, 164, 110)
--  menu.text:draw(menu.bg, 208, 110)
  menu.max_name:draw(menu.bg, X, Y + 14)
  menu.box:draw(menu.bg, X, Y)

  menu.bg:fade_in(FADE_IN_TIME)
  menu.moths:fade_in(FADE_IN_TIME)

  sol.timer.start(self, 2000, function()
    menu.moths:fade_out(FADE_OUT_TIME)
    menu.bg:fade_out(FADE_OUT_TIME)
  end)

  sol.timer.start(self, 3000, function()
    sol.menu.stop(self)
  end)
end

function menu:on_finished()

end

function menu:on_draw(dst)
  menu.bg:draw(dst)
  menu.moths:draw(dst, X, Y - 17)
end

return menu