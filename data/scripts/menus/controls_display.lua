--NOTE: This controls menu just shows a static controls diagram. This is being replaced with the button_mapping menu

local controls_menu = {}

local bg = sol.surface.create()

function controls_menu:on_started()
  local font, font_size = require("scripts/language_manager"):get_menu_font()

  bg:clear()
  local bg_image = sol.surface.create("menus/controls_background.png")
  local move = sol.text_surface.create({font=font, font_size=font_size})
  local switch_subscreen = sol.text_surface.create({font=font, font_size=font_size})
  local item1 = sol.text_surface.create({font=font, font_size=font_size})
  local item2 = sol.text_surface.create({font=font, font_size=font_size})
  local sword = sol.text_surface.create({font=font, font_size=font_size})
  local pause = sol.text_surface.create({font=font, font_size=font_size})
  local action = sol.text_surface.create({font=font, font_size=font_size})
  local action_2 = sol.text_surface.create({font=font, font_size=font_size})

  local quick_menus = sol.text_surface.create({font=font, font_size=font_size})
  local fullscreen = sol.text_surface.create({font=font, font_size=font_size})
  local f1 = sol.text_surface.create({font=font, font_size=font_size})


  move:set_text(sol.language.get_string("controls.move"))
  switch_subscreen:set_text(sol.language.get_string("controls.switch_subscreen"))
  item1:set_text(sol.language.get_string("controls.item1"))
  item2:set_text(sol.language.get_string("controls.item2"))
  sword:set_text(sol.language.get_string("controls.sword"))
  pause:set_text(sol.language.get_string("controls.pause"))

  quick_menus:set_text(sol.language.get_string("controls.quick_menus"))
  fullscreen:set_text(sol.language.get_string("controls.fullscreen"))
  f1:set_text(sol.language.get_string("controls.f1"))

  bg:fade_in(5)

  --Determine if Action/Enter Needs two lines or not
  local needs_two_lines = string.match(sol.language.get_string("controls.action"), "\\n")
  if needs_two_lines then
    local action_string = sol.language.get_string("controls.action").."\\n"
    local lines = {}
    for line in action_string:gmatch("(.-)\\n") do
      table.insert(lines, line)
    end
    action:set_text(lines[1])
    action_2:set_text(lines[2])
  else
    action:set_text(sol.language.get_string("controls.action"))
  end


  local OFFSET = -31
  local YSET = 8
  bg_image:draw(bg)
  move:draw(bg,104 + OFFSET,32 + YSET)
  switch_subscreen:draw(bg,270 + OFFSET,48 + YSET)
  pause:draw(bg,200 + OFFSET,192 + YSET)

  item1:draw(bg,298 + OFFSET,86 + YSET)
  item2:draw(bg,298 + OFFSET,102 + YSET)
  sword:draw(bg,298 + OFFSET,118 + YSET)
  action:draw(bg,298 + OFFSET,134 + YSET)
  action_2:draw(bg,298 + OFFSET,150 + YSET)

  quick_menus:draw(bg,298 + OFFSET,170 + YSET)
  fullscreen:draw(bg,298 + OFFSET,186 + YSET)
  f1:draw(bg,298 + OFFSET,202 + YSET)


end

function controls_menu:on_draw(dst)
  bg:draw(dst)
end

function controls_menu:on_command_pressed(cmd)
  sol.menu.stop(controls_menu)
  local handled = true
  return handled
end

function controls_menu:on_key_pressed(key)
  local handled
  if key == "f" or key == "g" then
    sol.menu.stop(controls_menu)
    handled = true
  end
  return handled
end



return controls_menu