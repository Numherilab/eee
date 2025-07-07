local carried_object_meta = sol.main.get_metatable("carried_object")

function carried_object_meta:on_breaking()
  local sprite_name = self:get_sprite():get_animation_set()
  if string.match(sprite_name, "bush") then
    sol.audio.play_sound("bush")
  end
  if string.match(sprite_name, "vase") then
    sol.audio.play_sound("breaking_vase")
  end
  if string.match(sprite_name, "stone") then
    sol.audio.play_sound("breaking_stone")
  end
end
