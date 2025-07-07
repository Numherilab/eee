local menu = {}
local parent_menu
local game_manager = require("scripts/game_manager")
--We don't show some options, depending on console/platform settings:
local IS_SWITCH = (sol.main.get_os() == "Nintendo Switch")
local DEMO_MODE = false

function sol.main.set_demo_mode(mode)
  DEMO_MODE = mode
  menu:on_started()
end

local selection_options = {
  "continue",
  "new",
  "options",
  "quit",
  -- "demo"
}

local font, font_size = require("scripts/language_manager"):get_menu_font()

local cursor_sprite = sol.sprite.create("menus/cursor")
local selection_surface = sol.surface.create(144, 72)
local text_surface = sol.text_surface.create({
        font = font, font_size = font_size,
        vertical_alignment = "top",
        horizontal_alignment = "left",
})
local text_surface2 = sol.text_surface.create({
        font = font, font_size = font_size,
        vertical_alignment = "top",
        horizontal_alignment = "left",
})
local text_surface3 = sol.text_surface.create({
        font = font, font_size = font_size,
        vertical_alignment = "top",
        horizontal_alignment = "left",
})
local text_surface4 = sol.text_surface.create({
        font = font, font_size = font_size,
        vertical_alignment = "top",
        horizontal_alignment = "left",
})
local text_surface5 = sol.text_surface.create({
        font = font, font_size = font_size,
        vertical_alignment = "top",
        horizontal_alignment = "left",
})

local confirming = false
local cursor_index
local MAX_CURSOR_INDEX = #selection_options - 1


function menu:update_font()
  font, font_size = require("scripts/language_manager"):get_menu_font()
  local surfaces_to_update = {text_surface, text_surface2, text_surface3, text_surface4, text_surface5}
  for _, txt_s in pairs(surfaces_to_update) do
    txt_s:set_font(font)
    txt_s:set_font_size(font_size)
  end
  --move menus left for japanese because it's so long
  if sol.language.get_language() == "ja" then
    sol.main.title_screen_options_draw_x = 300
  else
    sol.main.title_screen_options_draw_x = 324
  end
end

function menu:on_started()
  IS_SWITCH = (sol.main.get_os() == "Nintendo Switch")
  --remove "Quit" option for Switch
  if IS_SWITCH or sol.main.IS_UWP then
    MAX_CURSOR_INDEX = 2
  end
  menu:update_font()
  sol.main.title_menus[menu] = menu
  cursor_index = 0

  selection_surface:clear()

  --Fade in stuff so it's not as jarring
  selection_surface:fade_in()
  cursor_sprite:fade_in()

  if not sol.game.exists("save1.dat") then
    menu.no_save_game = true
    text_surface:set_color_modulation{100,100,100}
    cursor_index = 1
  end
  if DEMO_MODE then
    local darkened_color = {180, 170, 150}
    text_surface:set_color_modulation(darkened_color)
    text_surface2:set_color_modulation(darkened_color)
  end

  text_surface:set_text_key("menu.title.continue")
  text_surface:draw(selection_surface, 12, 0)
  text_surface2:set_text_key("menu.title.new_game")
  text_surface2:draw(selection_surface, 12, 16)
  text_surface5:set_text_key("menu.title.options")
  text_surface5:draw(selection_surface, 12, 32)
  text_surface3:set_text_key("menu.title.quit")
  if not IS_SWITCH and not sol.main.IS_UWP then
    text_surface3:draw(selection_surface, 12, 48)
  end
  -- text_surface4:set_text_key("menu.title.demo")
  -- text_surface4:draw(selection_surface, 12, 48)

end

function menu:set_parent_menu(dad)
  parent_menu = dad
end

function menu:on_draw(dst_surface)
  local x = sol.main.title_screen_options_draw_x
  local y = sol.main.title_screen_options_draw_y
  selection_surface:draw(dst_surface, x, y)
  cursor_sprite:draw(dst_surface, x + 3, y + 4 + cursor_index * 16)
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
    --Continue
    if selection == "continue" then
      if menu.no_save_game then sol.audio.play_sound"no" return end
      if DEMO_MODE then sol.audio.play_sound"no" return end

      --Validate Save:
      local validator = require("scripts/save_validator/validator")
      local valid = validator:is_valid("save1.dat")
      if valid then
        sol.audio.play_sound("elixer_upgrade")
        local game = game_manager:create("save1.dat")
        sol.main:start_savegame(game)
        sol.menu.stop(parent_menu)
      else
        --corrupted save
        sol.menu.start(menu, require"scripts/menus/title_screen_menus/corrupted_save")
      end


    --New Game?
    elseif selection == "new" then
      if DEMO_MODE then sol.audio.play_sound"no" return end
      sol.audio.play_sound("ok")
      local confirm_menu = require"scripts/menus/title_screen_menus/new_game_confirm"
      confirm_menu:set_parent_menu(parent_menu)
      parent_menu:set_current_submenu(confirm_menu)
      sol.menu.start(parent_menu, confirm_menu)
      sol.menu.stop(menu)


    --Options
    elseif selection == "options" then
      sol.audio.play_sound("ok")
      local options_menu = require"scripts/menus/title_screen_menus/options"
      options_menu:set_parent_menu(parent_menu)
      parent_menu:set_current_submenu(options_menu)
      sol.menu.start(parent_menu, options_menu)
      sol.menu.stop(menu)

    elseif  selection == "quit" then
      sol.main.exit()

    elseif selection == "demo" then
      sol.audio.play_sound("ok")
      local demo_menu
      if sol.game.exists("demo.dat") then demo_menu = require"scripts/menus/title_screen_menus/demo_continue" 
      else demo_menu = require"scripts/menus/title_screen_menus/demo_menu" end
      sol.menu.start(parent_menu, demo_menu)
      demo_menu:set_parent_menu(parent_menu)
      parent_menu:set_current_submenu(demo_menu)
      sol.menu.stop(menu)


    end --end cursor index cases
end


return menu