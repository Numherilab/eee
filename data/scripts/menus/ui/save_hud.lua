local save_hud = {}

local surface = sol.text_surface.create()

function save_hud:on_started()
  surface:set_text("Press C to Save")
  surface:fade_in()
end

function save_hud:on_finished()
  surface:fade_out()
end

function save_hud:on_draw(dst_surface)
  surface:draw(dst_surface, 10, 230)
end

return save_hud