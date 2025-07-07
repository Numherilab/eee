local sprite_meta = sol.main.get_metatable("sprite")

function sprite_meta:flash(duration)
  self:set_blend_mode("add")
  sol.timer.start(sol.main, duration or 150, function()
    self:set_blend_mode("blend")
  end)
end


return true