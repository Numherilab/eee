local respawn_screen = {}

local black_screen = sol.surface.create()
black_screen:fill_color({0,0,0})

function respawn_screen:on_draw(dst_surface)
  black_screen:draw(dst_surface)

end

return respawn_screen