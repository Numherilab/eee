local title_screen = {}

local command_manager = require("scripts/misc/command_binding_manager")
local settings = require"scripts/settings"
command_manager:init()

local current_submenu

sol.main.title_screen_options_draw_x = 324
sol.main.title_screen_options_draw_y = 172

function title_screen:on_started()
  settings:save() --if you've just come from language menu, save the chosen language
  sol.main.title_menus = {}
  sol.menu.start(title_screen, require"scripts/menus/title_screen_menus/background", false)
  local cont_new_etc = require"scripts/menus/title_screen_menus/new_continue_etc"
  sol.menu.start(title_screen, cont_new_etc)
  cont_new_etc:set_parent_menu(title_screen)
  current_submenu = cont_new_etc
end

function title_screen:set_current_submenu(new_menu)
  current_submenu = new_menu
end


local ALLOWED_COMMANDS = {
  down = true,
  up = true,
  action = true,
}

---KEYBOARD---------------------------------------------------------------

function title_screen:on_key_pressed(key)
  local command = command_manager:get_command_from_key(key)
  if ALLOWED_COMMANDS[command] then current_submenu:process_input(command) end

end


----JOYPAD---------------------------------------------------------------------
function title_screen:on_joypad_button_pressed(button)
  local command = command_manager:get_command_from_button(button)
  if ALLOWED_COMMANDS[command] then current_submenu:process_input(command) end
end

function title_screen:on_joypad_hat_moved(hat,direction8)
  local command = command_manager:get_command_from_hat(hat, direction8)
  if ALLOWED_COMMANDS[command] then current_submenu:process_input(command) end
end


--Avoid analog stick wildly jumping
local joy_avoid_repeat = {-2, -2}

function title_screen:on_joypad_axis_moved(axis,state)
  local handled = joy_avoid_repeat[axis] == state
  joy_avoid_repeat[axis] = state

  if not handled and not title_screen.joypad_just_moved then
    local command = command_manager:get_command_from_axis(axis, state)
    if ALLOWED_COMMANDS[command] then
      title_screen.joypad_just_moved = true
      sol.timer.start(sol.main, 50, function() title_screen.joypad_just_moved = false end)
      current_submenu:process_input(command)
      handled = true
    end
  end
  return handled
end


return title_screen
