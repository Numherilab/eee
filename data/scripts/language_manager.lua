-- This script provides configuration information about text and languages.
--
-- Usage:
-- local language_manager = require("scripts/language_manager")

local language_manager = {}

local default_language = "en"

-- Returns the id of the default language.
function language_manager:get_default_language()
  return default_language
end

-- Returns the font and font size to be used for dialogs
-- depending on the specified language (the current one by default).
function language_manager:get_dialog_font(language)
  language = language or sol.language.get_language()

  if language == "zh" then
    return "GnuUnifontFull", 16, 19
  elseif language == "ja" then
    return "JF-Dot-milkjf16", 16, 19
  elseif language == "ru" then
    return "slightly_narrow_basis", 16
  else
    return "enter_command", 16
  end
end

-- Returns the width, height, and line height in pixels of the frame drawn for the dialog
-- box menu depending on the specified language (the current one by default).
function language_manager:get_dialog_box_size(language)
  language = language or sol.language.get_language()

  if language == "zh" then
    return 320, 88, 18
  elseif language == "ja" then
    return 320, 88, 18
  elseif language == "ru" then
    return 312, 80, 16
  else
    return 304, 80, 16
  end
end

-- Returns the font and font size to be used to display text in menus
-- depending on the specified language (the current one by default).
function language_manager:get_menu_font(language)
  language = language or sol.language.get_language()

  if language == "zh" then
    return "GnuUnifontFull", 16, 19
  elseif language == "ja" then
    return "JF-Dot-milkjf16", 16, 19
  elseif language == "ru" then
    return "slightly_narrow_basis", 16
  else
    return "enter_command", 16
  end
end

-- Returns the font, font size and line offset to be used for text in the
-- world map depending on the specified language (the current one by default).
function language_manager:get_map_font(language)
  language = language or sol.language.get_language()

  if language == "zh" then
    return "GnuUnifontFull", 16
  elseif language == "ja" then
    return "JF-Dot-k12x10", 10
  elseif language == "ru" then
    return "slightly_narrow_basis", 16, 10
  elseif language == "en" then
    return "CartographerTiny", 7, 6
  else
    return "FiveByFive", 8, 8
  end
end

-- Returns the font, font size and banner height to be used for text in the
-- map banner depending on the specified language (the current one by default).
function language_manager:get_banner_font(language)
  language = language or sol.language.get_language()

  if language == "zh" then
    return "GnuUnifontFull", 16, 28
  elseif language == "ja" then
    return "JF-Dot-milkjf16", 16, 28
  elseif language == "ru" then
    return "basis33", 16, 28
  elseif language == "en" then
    return "oceansfont_medium", nil, 28
  else
    return "LitterLover2-Bold", 16, 28
  end
end

return language_manager
