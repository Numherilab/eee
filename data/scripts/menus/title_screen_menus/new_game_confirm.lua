local menu = {}
local parent_menu
local game_manager = require("scripts/game_manager")

local selection_options = {
 "yes",
 "no"
}

local font, font_size = require("scripts/language_manager"):get_menu_font()

local cursor_sprite = sol.sprite.create("menus/cursor")
local selection_surface = sol.surface.create(144, 72)
local text_surface = sol.text_surface.create({
        font = font, font_size = font_size,
        vertical_alignment = "top",
        horizontal_alignment = "left",
})
local text_surface_half = sol.text_surface.create({
        font = font, font_size = font_size,
        vertical_alignment = "top",
        horizontal_alignment = "left",
})
local text_surface2 = sol.text_surface.create({
        font = font, font_size = font_size,
        vertical_alignment = "top",
        horizontal_alignment = "left",
})

local cursor_index
local MAX_CURSOR_INDEX = 1


function menu:update_font()
  font, font_size = require("scripts/language_manager"):get_menu_font()
  local surfaces_to_update = {text_surface, text_surface_half, text_surface2}
  for _, txt_s in pairs(surfaces_to_update) do
    txt_s:set_font(font)
    txt_s:set_font_size(font_size)
  end
end

function menu:on_started()
  sol.main.title_menus[menu] = menu
  cursor_index = 0

  selection_surface:clear()

  menu.needs_two_lines = string.match(sol.language.get_string("menu.title.clear_save"), "\\n")

  if menu.needs_two_lines then
    menu.cursor_jump_dist = 32
    local clear_string = sol.language.get_string("menu.title.clear_save").."\\n"
    local lines = {}
    for line in clear_string:gmatch("(.-)\\n") do
      table.insert(lines, line)
    end
    text_surface:set_text(lines[1])
    text_surface_half:set_text(lines[2])
    text_surface:draw(selection_surface, 12, 0)
    text_surface_half:draw(selection_surface, 12, 12)
    text_surface2:set_text_key("menu.title.cancel")
    text_surface2:draw(selection_surface, 12, 32)
  else
    menu.cursor_jump_dist = 16
    text_surface:set_text_key("menu.title.clear_save")
    text_surface:draw(selection_surface, 12, 0)
    text_surface2:set_text_key("menu.title.cancel")
    text_surface2:draw(selection_surface, 12, 16)
  end

  --if there is no savegame yet, then ignore the rest of the menu, basically
  if not sol.game.exists("save1.dat") then
    local game = game_manager:create("save1.dat", true)
    sol.main:start_savegame(game)
    sol.menu.stop(parent_menu)
    return
  end

end

function menu:set_parent_menu(dad)
  parent_menu = dad
end

function menu:on_draw(dst_surface)
  local x = sol.main.title_screen_options_draw_x
  local y = sol.main.title_screen_options_draw_y + 10
  selection_surface:draw(dst_surface, x, y)
  cursor_sprite:draw(dst_surface, x + 3, y + 4 + cursor_index * menu.cursor_jump_dist)
end


function menu:process_input(command)
  if command == "down" then
      sol.audio.play_sound("cursor")
      cursor_index = cursor_index + 1
      if cursor_index > MAX_CURSOR_INDEX then cursor_index = 0 end
  elseif command == "up" then
      sol.audio.play_sound("cursor")
      cursor_index = cursor_index - 1
      if cursor_index <0 then cursor_index = MAX_CURSOR_INDEX end


  elseif command == "action" then
    menu:process_selected_option(selection_options[cursor_index + 1])
  end
end


function menu:process_selected_option(selection)
    --Confirm
    if selection == "yes" then
      sol.audio.play_sound("elixer_upgrade")
      local game = game_manager:create("save1.dat", true)
      sol.main:start_savegame(game)
      sol.menu.stop(parent_menu)

    --Cancel
    elseif selection == "no" then
      sol.audio.play_sound("no")
      local new_cont_etc = require"scripts/menus/title_screen_menus/new_continue_etc"
      sol.menu.start(parent_menu, new_cont_etc)
      parent_menu:set_current_submenu(new_cont_etc)
      new_cont_etc:set_parent_menu(parent_menu)
      sol.menu.stop(menu)

    end --end cursor index cases
end


return menu