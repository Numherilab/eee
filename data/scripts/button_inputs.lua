require("scripts/multi_events")

local menu = {}
local pause_menu = require"scripts/menus/pause_menu"
local button_menu = require"scripts/menus/button_mapping"
local dash_manager = require"scripts/action/dash_manager"

local MENU_DIRECTIONS = {
	prev_menu = "left",
	next_menu = "right",
}

function menu:initialize(game)
  local pause_menu = require"scripts/menus/pause_menu"
  local button_mapping_menu = require"scripts/menus/button_mapping"
  local quest_log = require"scripts/menus/quest_log"
  local dash_manager = require"scripts/action/dash_manager"
  local command_manager = require"scripts/misc/command_binding_manager"
  local debug_menu = require"scripts/menus/debug_menu"

  local function next_submenu(direction)
    if sol.menu.is_started(pause_menu) and not sol.menu.is_started(button_menu) then
      pause_menu:next_submenu(direction)
    end
  end

  function game:on_joypad_button_pressed(button)
    local command = command_manager:get_command_from_button(button)
    local direction = MENU_DIRECTIONS[command]
    local submenu_index = command and command:match"^menu_(%d+)$"
    if direction then
        next_submenu(direction)
    elseif submenu_index and not game:is_dialog_enabled() and not sol.menu.is_started(button_menu) then
        pause_menu:toggle_submenu(submenu_index)
        return true
    end
    --Hardcoded debug button for switch:
    if sol.main.get_os() == "Nintendo Switch" and button == 15 then
      local debug_menu = require"scripts/menus/debug_menu"
      debug_menu:init(game)
      if sol.menu.is_started(debug_menu) then
        sol.menu.stop(debug_menu)
      else
        sol.menu.start(game, debug_menu)
      end
    end
  end

  function game:on_joypad_axis_moved(axis, state)
    local command = command_manager:get_command_from_axis(axis, state)
    local direction = MENU_DIRECTIONS[command]
    local submenu_index = command and command:match"^menu_(%d+)$"
    if direction and state~=0 then
        next_submenu(direction)
    elseif submenu_index and not game:is_dialog_enabled() and not sol.menu.is_started(button_menu) then
        pause_menu:toggle_submenu(submenu_index)
        return true
    end
  end

  function game:on_joypad_hat_moved(hat, direction8)
    local command = command_manager:get_command_from_hat(hat, direction8)
    local direction = MENU_DIRECTIONS[command]
    local submenu_index = command and command:match"^menu_(%d+)$"
    if direction and hat>=0 then
        next_submenu(direction)
    elseif submenu_index and not game:is_dialog_enabled() and not sol.menu.is_started(button_menu) then
        pause_menu:toggle_submenu(submenu_index)
        return true
    end
  end

  game:register_event("on_key_pressed", function(self, key, modifiers)
    local hero = game:get_hero()

    local command = command_manager:get_command_from_key(key)
    local submenu_index = command and command:match"^menu_(%d+)$"
    if submenu_index and not game:is_dialog_enabled() and not sol.menu.is_started(button_menu) then
        --Return if pause isn't allowed:
        if not game:is_pause_allowed() then return true end
        --open (or close if already open) the corresponding pause submenu directly
        pause_menu:toggle_submenu(submenu_index)
        return true
    elseif command == "prev_menu" and sol.menu.is_started(pause_menu) then
      next_submenu"left"
    elseif command == "next_menu" and sol.menu.is_started(pause_menu) then
      next_submenu"right"

    elseif key == "escape" then
      game:simulate_command_pressed"pause"

    elseif key == "f1" and not game:is_dialog_enabled() and not game:is_paused() then
      if not sol.menu.is_started(button_menu) then
        sol.menu.start(game, button_menu)
      else
        sol.menu.stop(button_menu)
      end
    end

  end)

  function game:on_key_released(key)
    if key == "return" then
      game:simulate_command_released"action"
    end
  end


  local can_dash = true
  function game:on_command_pressed(action)
    local ignoring_obstacles
    local hero = game:get_hero()
    local map = game:get_map()

    if action == "action" and hero:get_state() == "free" and game:get_command_effect"action" == nil
    and hero:get_controlling_stream() == nil then
      if hero:get_facing_entity() and hero:get_facing_entity().on_interaction then return end
      local dx = {[0] = 8, [1] = 0, [2] = -8, [3] = 0}
      local dy = {[0] = 0, [1] = -8, [2] = 0, [3] = 8}
      local direction = hero:get_direction()
      local has_space = not hero:test_obstacles(dx[direction], dy[direction])
      if not game:is_suspended() and can_dash and has_space then
        dash_manager:dash(game)
        can_dash = false
        sol.timer.start(game, 500, function() can_dash = true end)
      end

    elseif game.spirit_counter_roll and action == "action" and hero:is_blinking() and not game:is_suspended() then
      local x, y, z = hero:get_position()
      sol.audio.play_sound"sword_beam"
      map:create_custom_entity{x=x,y=y,layer=z,width=16,height=16,direction=0,
        model="damaging_sparkle",sprite="entities/spirit_counter"
      }
    end
  end


  function game:set_controller_type(type)
    local mapping = require("scripts/joypad_defaults/" .. type)
    for button, command in pairs(mapping.button) do
      game:set_command_joypad_binding(command, "button " .. button)
    end
  end
  
end

return menu