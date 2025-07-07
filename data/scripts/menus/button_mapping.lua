local language_manager = require("scripts/language_manager")
local command_manager = require("scripts/misc/command_binding_manager")
local multi_events = require"scripts/multi_events"

local options_submenu = {x=0, y=0}
local line_height

multi_events:enable(options_submenu)

local COMMAND_NAMES = {
  "up", "down", "left", "right", "action", "attack", "item_1", "item_2", "pause",
  --custom commands:
  "next_menu", "prev_menu", "menu_1", "menu_2", "menu_3", "menu_4",
}
for i=1,9 do COMMAND_NAMES[ COMMAND_NAMES[i] ] = true end --first 9 commands are the built-in ones
local NUM_ROWS = #COMMAND_NAMES + 1

local WIDE_CURSOR_NAME = "wide_15"
local WIDE_BLINK_CURSOR_NAME = "wide_blink_15"


--// Gets/sets the x,y position of the menu in pixels
function options_submenu:get_xy() return self.x, self.y end
function options_submenu:set_xy(x, y)
    x = tonumber(x)
    assert(x, "Bad argument #2 to 'set_xy' (number expected)")
    y = tonumber(y)
    assert(y, "Bad argument #3 to 'set_xy' (number expected)")

    self.x = math.floor(x)
    self.y = math.floor(y)
end


function options_submenu:on_finished()
  local game = sol.main.get_game()
  if game then game:set_suspended(false) end
end

function options_submenu:on_started()
  local game = sol.main.get_game()
  if game then game:set_suspended(true) end

  command_manager:init()

  local width, height = sol.video.get_quest_size()
  local center_x, center_y = width / 2, height / 2

  self.intermediary_surface = sol.surface.create()
  self.dark_surface = sol.surface.create()
  self.dark_surface:fill_color({0,0,0,200})
  --From pause_submenu module
  self.background_surfaces = sol.surface.create("menus/pause_submenus.png")
  self.background_surfaces:set_opacity(255)
  --self.save_dialog_sprite = sol.sprite.create("menus/pause_save_dialog")
  self.save_dialog_state = 0
  self.text_color = { 115, 59, 22 }

  --local dialog_font, dialog_font_size = language_manager:get_dialog_font()
  local menu_font, menu_font_size, offset = language_manager:get_menu_font()
  line_height = offset or 16

  WIDE_CURSOR_NAME = "wide_"..(line_height - 1)
  WIDE_BLINK_CURSOR_NAME = "wide_blink_"..(line_height - 1)

  self.question_text_1 = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    color = self.text_color,
    font = menu_font,
    font_size = menu_font_size,
  }
  self.question_text_2 = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    color = self.text_color,
    font = menu_font,
    font_size = menu_font_size,
  }
--[[
  self.answer_text_1 = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    color = self.text_color,
    text_key = "save_dialog.yes",
    font = menu_font,
    font_size = menu_font_size,
  }
  self.answer_text_2 = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    color = self.text_color,
    text_key = "save_dialog.no",
    font = menu_font,
    font_size = menu_font_size,
  }
--]]

  self.caption_text_1 = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    font = menu_font,
    font_size = menu_font_size,
    color = self.text_color,
  }

  self.caption_text_2 = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    font = menu_font,
    font_size = menu_font_size,
    color = self.text_color,    
  }
  --end from pause_submenu module

  self.column_color = { 255, 255, 255}
  self.text_color = { 255, 255, 255 }

  self.fullscreen_label_text = sol.text_surface.create{
    horizontal_alignment = "right",
    vertical_alignment = "middle",
    font = menu_font,
    font_size = menu_font_size,
    text_key = "selection_menu.options.fullscreen",
    color = self.text_color,
  }
  self.fullscreen_label_text:set_xy(center_x - 4, center_y - 66)

  self.fullscreen_text = sol.text_surface.create{
    horizontal_alignment = "right",
    vertical_alignment = "middle",
    font = menu_font,
    font_size = menu_font_size,
    text_key = "selection_menu.options.fullscreen_"..tostring(sol.video.is_fullscreen()),
    color = self.text_color,
  }
  self.fullscreen_text:set_xy(center_x + 180, center_y - 66)

  self.command_column_text = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    font = menu_font,
    font_size = menu_font_size,
    text_key = "options.commands_column",
    color = self.column_color,
  }
  self.command_column_text:set_xy(center_x - 90, center_y - 44)

  self.keyboard_column_text = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    font = menu_font,
    font_size = menu_font_size,
    text_key = "options.keyboard_column",
    color = self.column_color,
  }
  self.keyboard_column_text:set_xy(center_x + 48, center_y - 44)

  self.joypad_column_text = sol.text_surface.create{
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    font = menu_font,
    font_size = menu_font_size,
    text_key = "options.joypad_column",
    color = self.column_color,
  }
  self.joypad_column_text:set_xy(center_x + 138, center_y - 44)

  self.commands_surface = sol.surface.create(364, #COMMAND_NAMES*line_height)
  self.commands_surface:set_xy(center_x - 182, center_y - 32)
  self.commands_highest_visible = 1
  self.commands_visible_y = 0
  self.num_commands_visible = math.floor(96/line_height)

  self.command_texts = {}
  self.keyboard_texts = {}
  self.joypad_texts = {}

  for i,command in ipairs(COMMAND_NAMES) do
    self.command_texts[i] = sol.text_surface.create{
      horizontal_alignment = "right",
      vertical_alignment = "top",
      font = menu_font,
      font_size = menu_font_size,
      text_key = "options.command." .. command,
      color = self.text_color,
    }

    self.keyboard_texts[i] = sol.text_surface.create{
      horizontal_alignment = "left",
      vertical_alignment = "top",
      font = menu_font,
      font_size = menu_font_size,
      color = self.text_color,
    }

    self.joypad_texts[i] = sol.text_surface.create{
      horizontal_alignment = "left",
      vertical_alignment = "top",
      font = menu_font,
      font_size = menu_font_size,
      color = self.text_color,
    }
  end

  self:load_command_texts()

  self.up_arrow_sprite = sol.sprite.create("menus/arrows")
  self.up_arrow_sprite:set_animation("arrow_up")
  self.up_arrow_sprite:set_xy(center_x - 90, center_y - 36)
  self.down_arrow_sprite = sol.sprite.create("menus/arrows")
  self.down_arrow_sprite:set_animation("arrow_down")
  self.down_arrow_sprite:set_xy(center_x - 90, center_y + 64)
  self.cursor_sprite = sol.sprite.create("menus/options_cursor")
  self.cursor_position = nil
  self:set_cursor_position(1)

end


-- Sets the caption text.
-- The caption text can have one or two lines, with 20 characters maximum for each line.
-- If the text you want to display has two lines, use the '$' character to separate them.
-- A value of nil removes the previous caption if any.
function options_submenu:set_caption(text_key)

  if text_key == nil then
    self.caption_text_1:set_text(nil)
    self.caption_text_2:set_text(nil)
  else
    local text = sol.language.get_string(text_key)
    if text == nil then
      self.caption_text_1:set_text(nil)
      self.caption_text_2:set_text(nil)
      return
    end
    local line1, line2 = text:match("([^$]+)%$(.*)")
    if line1 == nil then
      -- Only one line.
      self.caption_text_1:set_text(text)
      self.caption_text_2:set_text(nil)
    else
      -- Two lines.
      self.caption_text_1:set_text(line1)
      self.caption_text_2:set_text(line2)
    end
  end
end


-- Draw the caption text previously set.
function options_submenu:draw_caption(dst_surface)

  local width, height = dst_surface:get_size()

  if self.caption_text_2:get_text():len() == 0 then
    self.caption_text_1:draw(dst_surface, width / 2, height / 2 - 90)
  else
    self.caption_text_1:draw(dst_surface, width / 2, height / 2 - 96)
    self.caption_text_2:draw(dst_surface, width / 2, height / 2 - 84)
  end
end

--[[
function options_submenu:draw_background(dst_surface)
  local submenu_index = 1
  local width, height = dst_surface:get_size()
  self.background_surfaces:draw_region(
      0, 0, 320, 240,
      dst_surface, (width - 320) / 2, (height - 240) / 2)
end
--]]

function options_submenu:draw_save_dialog_if_any(dst_surface)

  if self.save_dialog_state > 0 then
    local width, height = dst_surface:get_size()
    local x = width / 2
    local y = height / 2
    --self.save_dialog_sprite:draw(dst_surface, x - 110, y - 33)
    self.question_text_1:draw(dst_surface, x, y - 16)
    self.question_text_2:draw(dst_surface, x, y)
    self.answer_text_1:draw(dst_surface, x - 60, y + 24)
    self.answer_text_2:draw(dst_surface, x + 59, y + 24)
  end
end


-- Loads the text displayed for each game command, for the
-- keyboard and the joypad.
function options_submenu:load_command_texts()

  self.commands_surface:clear()
  for i,command in ipairs(COMMAND_NAMES) do
    local keyboard_binding = command_manager:get_command_keyboard_binding(command) or "none"
    local joypad_binding = command_manager:get_command_joypad_binding(command) or "none"
    self.keyboard_texts[i]:set_text(keyboard_binding:sub(1, 15))
    self.joypad_texts[i]:set_text(joypad_binding:sub(1, 15))

    local y = line_height * (i - 1) + 2
    self.command_texts[i]:draw(self.commands_surface, 180, y)
    self.keyboard_texts[i]:draw(self.commands_surface, 190, y)
    self.joypad_texts[i]:draw(self.commands_surface, 280, y)
  end
end

function options_submenu:set_cursor_position(position)

  if position ~= self.cursor_position then
    --Hacky fix to avoid toggling fullscreen in UWP builds. Breaks looping from top to bottom. I apologize for this sin.
    if sol.main.IS_UWP and (position == 1) then
      position = 2
    end

    local width, height = sol.video.get_quest_size()

    self.cursor_position = position
    if position == 1 then  -- Video mode.
      self:set_caption("options.caption.press_action_change_mode")
      self.cursor_sprite.x = width / 2 - 180
      self.cursor_sprite.y = height / 2 - 73
      self.cursor_sprite:set_animation(WIDE_CURSOR_NAME)
    else  -- Customization of a command.
      self:set_caption("options.caption.press_action_customize_key")

      -- Make sure the selected command is visible.
      while position <= self.commands_highest_visible do
        self.commands_highest_visible = self.commands_highest_visible - 1
        self.commands_visible_y = self.commands_visible_y - line_height
      end

      while position > self.commands_highest_visible + self.num_commands_visible do
        self.commands_highest_visible = self.commands_highest_visible + 1
        self.commands_visible_y = self.commands_visible_y + line_height
      end

      self.cursor_sprite.x = width / 2 - 180
      self.cursor_sprite.y = height / 2 - 29 + line_height * (position - self.commands_highest_visible - 1)
      self.cursor_sprite:set_animation(WIDE_CURSOR_NAME)
    end
  end
end

function options_submenu:on_draw(dst_surface)
  self.dark_surface:draw(dst_surface)
  self.intermediary_surface:draw(dst_surface, self.x, self.y)
  dst_surface = self.intermediary_surface --this is a bit hacky instead of replacing lower dst_surfaces with self.intermediary_surface

  self.background_surfaces:draw(dst_surface)
  self:draw_caption(dst_surface)

  -- Cursor.
  self.cursor_sprite:draw(dst_surface, self.cursor_sprite.x, self.cursor_sprite.y)

  -- Text.
  if not sol.main.IS_UWP then
    self.fullscreen_label_text:draw(dst_surface)
    self.fullscreen_text:draw(dst_surface)
  end
  self.command_column_text:draw(dst_surface)
  self.keyboard_column_text:draw(dst_surface)
  self.joypad_column_text:draw(dst_surface)
  self.commands_surface:draw_region(0, self.commands_visible_y, 364, 96, dst_surface)

  -- Arrows.
  if self.commands_visible_y > 0 then
    self.up_arrow_sprite:draw(dst_surface)
  end

  if self.commands_visible_y < line_height * (#COMMAND_NAMES - self.num_commands_visible) then
    self.down_arrow_sprite:draw(dst_surface)
  end

  self:draw_save_dialog_if_any(dst_surface)
end


function options_submenu:on_command_pressed(command)
  return false
end


--Prevent analog sticks from wild jumping, standard joy_repeat thing didn't work
local wild_jump_freeze_down = false
local wild_jump_freeze_up = false

--can't use normal game commands here because game may not active, so use custom implementation instead
local function on_command_pressed(self, command)

  if self.command_customizing ~= nil then
    -- We are customizing a command: any key pressed should have been handled before.
    error("options_submenu:on_command_pressed() should not called in this state")
  end

  local handled = options_submenu.on_command_pressed(self, command)

  if not handled then
    if command == "up" and not wild_jump_freeze_up then
      wild_jump_freeze_up = true
      sol.timer.start(options_submenu, 150, function() wild_jump_freeze_up = false end)
      sol.audio.play_sound("cursor")
      self:set_cursor_position((self.cursor_position + NUM_ROWS - 2) % NUM_ROWS + 1)
      handled = true
    elseif command == "down" and not wild_jump_freeze_down then
      wild_jump_freeze_down = true
      sol.timer.start(options_submenu, 150, function() wild_jump_freeze_down = false end)
      sol.audio.play_sound("cursor")
      self:set_cursor_position(self.cursor_position % NUM_ROWS + 1)
      handled = true
    elseif command == "left" or command == "right" then
      handled = true
    elseif command == "attack" or command == "pause" then
      sol.menu.stop(options_submenu)
      handled = true
    elseif command == "action" then
      sol.audio.play_sound("danger")
      if self.cursor_position == 1 then
        local is_fullscreen = sol.video.is_fullscreen()
        sol.video.set_fullscreen(not is_fullscreen)
        self.fullscreen_text:set_text_key("selection_menu.options.fullscreen_"..tostring(not is_fullscreen))
      else
        -- Customize a game command.
        self:set_caption("options.caption.press_key")
        self.cursor_sprite:set_animation(WIDE_BLINK_CURSOR_NAME)
        local command_to_customize = COMMAND_NAMES[self.cursor_position - 1]
        self.is_prevent_close = true
        command_manager:capture_command_binding(command_to_customize, function(is_success)
          self.is_prevent_close = false
          if is_success then
            sol.audio.play_sound("danger")
            self:load_command_texts()
          else sol.audio.play_sound("no") end

          self:set_caption("options.caption.press_action_customize_key")
          self.cursor_sprite:set_animation(WIDE_CURSOR_NAME)
        end)
      end
      handled = true

--    elseif command == "pause" or command == "attack" then
--      sol.menu.stop(self)
    end
  end
  handled = true
  return handled
end

function options_submenu:on_key_pressed(key, modifiers)
  self.fullscreen_text:set_text_key("selection_menu.options.fullscreen_"..tostring(sol.video.is_fullscreen())) --check incase keyboard shortcut was used
  if key=="escape" then sol.menu.stop(self); return true end
  local command = command_manager:get_command_from_key(key)
  return command and on_command_pressed(self, command) or false
end

function options_submenu:on_key_released(key, modifiers)
  self.fullscreen_text:set_text_key("selection_menu.options.fullscreen_"..tostring(sol.video.is_fullscreen())) --check incase keyboard shortcut was used
end

function options_submenu:on_joypad_button_pressed(button)
  local command = command_manager:get_command_from_button(button)
  return command and on_command_pressed(self, command) or false
end

function options_submenu:on_joypad_hat_moved(hat, direction8)
  local command = command_manager:get_command_from_hat(hat, direction8)
  return command and on_command_pressed(self, command) or false
end

--Avoid analog stick wildly jumping
local joy_avoid_repeat = {-2, -2}
function options_submenu:on_joypad_axis_moved(axis, state)
  local handled = joy_avoid_repeat[axis] == state
  joy_avoid_repeat[axis] = state

  if not handled then
    local command = command_manager:get_command_from_axis(axis, state)
    return command and on_command_pressed(self, command) or false
  end

  return handled
end

return options_submenu

