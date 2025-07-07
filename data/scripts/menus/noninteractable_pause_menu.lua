local menu = {}

local pause_surface = sol.surface.create"menus/pause/noninteractable_screen.png"

function menu:on_draw(dst)
  pause_surface:draw(dst)
end

function menu:on_command_pressed(cmd)
  local handled = false
  if cmd == "pause" then
    sol.main.get_game():set_paused(false)
    sol.menu.stop(menu)
    handled = true
  end
  return handled
end

return menu