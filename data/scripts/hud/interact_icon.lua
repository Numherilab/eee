local interact_icon_builder = {}

local language_scales = {
  de = {width = 1.5, height = 1},
  es = {width = 1.4, height = 1},
  fr = {width = 1.2, height = 1},
  ja = {width = 1.9, height = 1.2},
  pt = {width = 1.2, height = 1},
  ru = {width = 1.9, height = 1.1},
  zh = {width = 1, height = 1.3},
}

function interact_icon_builder:new(game, config)
  local icon  = {}
  icon.x = config.x
  icon.y = config.y
  icon.current_text = ""

  local icon_surface = sol.surface.create(96, 32)
  icon_surface:set_opacity(0)
  local icon_box = sol.surface.create("hud/interact_icon.png", false)
  icon_box:set_transformation_origin(0,0)
  icon_box:set_opacity(0)
  local font, font_size = require("scripts/language_manager"):get_dialog_font()
  local icon_text = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    font = font, font_size = font_size,
  }

  local function check()
    local effect = game:get_command_effect("action")
    if effect == "speak" then effect = "interact"
    elseif effect == "swim" then effect = nil
    end
    if effect then effect = "menu.hud.command_effect." .. effect end
    if effect ~= icon.current_text then
      icon.current_text = effect
      icon_surface:clear()
      if effect == nil then
        icon_surface:fade_out(5)
      else
        icon_text:set_text_key(effect)
        icon_surface:fade_in(5)
        icon_box:set_opacity(255) --don't make opaque until now otherwise you get 1 fame visible as game starts
      end
      icon_box:draw(icon_surface, 0, 2)
      icon_text:draw(icon_surface, icon.middle_x, icon.middle_y + 2)
    end
    return true
  end


  function icon:on_draw(dst)
    icon_surface:draw(dst, icon.x, icon.y)
  end

  function icon:on_started()
    --Scale box for the big languages
    local scale_x, scale_y = 1, 1
    for language, settings in pairs(language_scales) do
      if sol.language.get_language() == language then
        scale_x = settings.width
        scale_y = settings.height
      end
    end
    icon_box:set_scale(scale_x, scale_y)

    icon.width, icon.height = icon_box:get_size()
    icon.middle_x = icon.width * scale_x / 2
    icon.middle_y = icon.height * scale_y / 2
    icon_surface:set_opacity(0)
    sol.timer.start(icon, 50, check)
  end

  return icon
end

return interact_icon_builder