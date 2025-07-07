-- Language selection menu.
-- If a language is already set, we skip this menu.

local language_menu = {}

local language_manager = require("scripts/language_manager")
local command_manager = require("scripts/misc/command_binding_manager")

local settings = require"scripts/settings"

function language_menu:on_started()
  if sol.language.get_language() ~= nil and not language_menu.choose_new_language then
    -- A language is already set: skip this screen.
    sol.menu.stop(self)
  else

    local screen_width, screen_height = sol.video.get_quest_size()
    local ids = sol.language.get_languages()
    local index = 1
    local cursor_position = 1
    self.surface = sol.surface.create(320, screen_height)
    self.dark_bg = sol.surface.create(100, screen_height)
    self.dark_bg:fill_color({0,0,0})
    self.dark_bg:set_opacity(100)
    self.finished = false
    self.first_visible_language = 1
    self.max_visible_languages = 10
    self.nb_visible_languages = math.min(#ids, self.max_visible_languages)
    self.languages = {}
    for _, id in ipairs(ids) do
      local language = {}
      local font, font_size = language_manager:get_dialog_font(id)
      language.id = id
      language.text = sol.text_surface.create{
        font = font,
        font_size = font_size,
        text = sol.language.get_language_name(id),
        horizontal_alignment = "center"
      }

      if id == language_manager:get_default_language() then
        cursor_position = index
      end

      self.languages[index] = language
      index = index + 1
    end

    if #self.languages <= 1 then
      -- No choice: skip this screen.
      if #self.languages == 1 then
        sol.language.set_language(self.languages[1].id)
      end
      sol.menu.stop(self)
    else
      self:set_cursor_position(cursor_position)
    end
  end
end

function language_menu:on_draw(dst_surface)
  self.surface:clear()

  self.dark_bg:draw(self.surface, 320/2-50)

  local y = 120 - 12 * self.nb_visible_languages
  local first = self.first_visible_language
  local last = self.first_visible_language + self.nb_visible_languages - 1
  for i = first, last do
    self.languages[i].y = y
    y = y + 24
    self.languages[i].text:draw(self.surface, 160, y)
  end

  -- The menu makes 320*240 pixels, but dst_surface may be larger.
  local width, height = dst_surface:get_size()
  self.surface:draw(dst_surface, width / 2 - 160, height / 2 - 120)
end



function language_menu:process_selection()
  if not self.finished then
    handled = true
    local language = self.languages[self.cursor_position]
    sol.language.set_language(language.id)
    
    --Update title screen menus
    if sol.main.title_menus then
      for _, m in pairs(sol.main.title_menus) do
        m:update_font()
      end
    end
    self.finished = true
    self.surface:fade_out()
    sol.timer.start(self, 700, function()
      settings:save()
      sol.menu.stop(self)
    end)
  end
end



local ALLOWED_COMMANDS = {
  down = true,
  up = true,
  action = true,
}

function language_menu:on_key_pressed(key)
  local handled = false
  local command = command_manager:get_command_from_key(key)
  if ALLOWED_COMMANDS[command] and command == "action" then
    language_menu:process_selection()
    handled = true
  elseif ALLOWED_COMMANDS[command] then
    language_menu:direction_pressed(command)
    handled = true
  end
  return handled
end

function language_menu:on_joypad_button_pressed(button)
  local handled = false
  local command = command_manager:get_command_from_button(button)
  if ALLOWED_COMMANDS[command] and command == "action" then
    language_menu:process_selection()
    handled = true
  end
  return handled
end

function language_menu:on_joypad_hat_moved(hat,direction8)
  local handled = false
  local command = command_manager:get_command_from_hat(hat, direction8)
  if ALLOWED_COMMANDS[command] then language_menu:direction_pressed(command); handled = true end
  return handled
end




--Avoid analog stick wildly jumping
local joy_avoid_repeat = {-2, -2}

function language_menu:on_joypad_axis_moved(axis,state)
  local handled = joy_avoid_repeat[axis] == state
  joy_avoid_repeat[axis] = state

  if not handled then
    local command = command_manager:get_command_from_axis(axis, state)
    if ALLOWED_COMMANDS[command] then
      language_menu.joypad_just_moved = true
      sol.timer.start(sol.main, 50, function() language_menu.joypad_just_moved = false end)
      language_menu:direction_pressed(command)
      handled = true
    end
  end
  return handled
end


function language_menu:direction_pressed(command)

  local handled = false

  if not self.finished then

    local n = #self.languages
    if command == "up" then  -- Up.
      sol.audio.play_sound("cursor")
      self:set_cursor_position((self.cursor_position + n - 2) % n + 1)
      handled = true
    elseif command == "down" then  -- Down.
      sol.audio.play_sound("cursor")
      self:set_cursor_position(self.cursor_position % n + 1)
      handled = true
    end
  end

  return handled
end



function language_menu:set_cursor_position(cursor_position)

  if self.cursor_position ~= nil then
    self.languages[self.cursor_position].text:set_color{255, 255, 255}
  end
  self.languages[cursor_position].text:set_color{255, 255, 0}

  if cursor_position < self.first_visible_language then
    self.first_visible_language = cursor_position
  end

  if cursor_position >= self.first_visible_language + self.max_visible_languages then
    self.first_visible_language = cursor_position - self.max_visible_languages + 1
  end

  self.cursor_position = cursor_position
end

return language_menu

