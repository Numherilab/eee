-- This is the main Lua script of your project.
-- You will probably make a title screen and then start a game.
-- See the Lua API! http://www.solarus-games.org/doc/latest

require("scripts/features")
local settings = require"scripts/settings"

--GLOBAL DEBUG MODE
sol.main.debug_mode = false
sol.main.IS_UWP = false
if sol.file.exists"debug.lua" then sol.main.debug_mode = true end
if sol.main.get_os() == "Nintendo Switch" then sol.main.debug_mode = false end

-- This function is called when Solarus starts.
function sol.main:on_started()

  --local is_new_install = not sol.file.exists("settings.dat")
  settings:load()

--[[  if is_new_install then
    sol.video.set_fullscreen(true)
  end
  if sol.video.is_fullscreen() then
    sol.video.set_cursor_visible(false)
  end --]]

  --preload the sounds for faster access
  sol.audio.preload_sounds()

  --Set the window title.
  sol.video.set_window_title("Ocean's Heart")

  --Hide cursor
  sol.video.set_cursor_visible(not sol.video.is_fullscreen())

  --Start initial menus:
  sol.timer.start(sol.main, 100, function()
    require("scripts/menus/initial_menus").start()

    --Load steam functionality. If module is missing, sol.steam will be nil, but shouldn't crash
    function loadrequire(module_name)
        local res = pcall(require,module_name)
        if not(res) then
            -- Do Stuff when no module
          print("Luasteam not found. Steam functionality unavailable")
        end
    end
    loadrequire("scripts/steam/steam_init")
  end)

end



-- Event called when the player pressed a keyboard key.
sol.main:register_event("on_key_pressed", function(self, key, modifiers)


  local handled = false
  if key == "f11" or
    (key == "return" and (modifiers.alt or modifiers.control)) then
    -- F11 or Ctrl + return or Alt + Return: switch fullscreen.
    if sol.main.IS_UWP then return end
    local is_fullscreen = sol.video.is_fullscreen()
    sol.video.set_fullscreen(not is_fullscreen)
    sol.video.set_cursor_visible(is_fullscreen) -- hide mouse on fullscreen
    handled = true
  elseif key == "f4" and modifiers.alt then
    -- Alt + F4: stop the program.
    sol.main.exit()
    handled = true

  end

  return handled
end)

--Starts a game.
function sol.main:start_savegame(game)
  sol.main.game = game
  game:start()
end

--Called when app stops
function sol.main:on_finished()
  settings:save()
  if sol.steam then sol.steam.shutdown() end
end
