
require("scripts/multi_events")
require("scripts/weather/weather_manager")
local game_restart = require("scripts/game_restart")
local initial_game = require("scripts/initial_game")
local pause_menu = require"scripts/menus/pause_menu"
local noninteractable_pause_menu = require"scripts/menus/noninteractable_pause_menu"
local controls_menu = require"scripts/menus/controls_display"
local button_mapping_menu = require"scripts/menus/button_mapping"
--local quest_log = require"scripts/menus/quest_log"
--local pause_inventory = require"scripts/menus/inventory"
local quest_update_icon = require"scripts/menus/quest_update_icon"
local objectives_manager = require"scripts/objectives_manager"
local dash_manager = require"scripts/action/dash_manager"
local map_banner = require"scripts/menus/map_banner"
local world_map = require"scripts/world_map"
local button_inputs_manager = require("scripts/button_inputs")
local debug_keys_manager = require("scripts/debug_keys")
local gameover_and_respawn_manager = require"scripts/gameover_and_respawn"
local debug_menu = require"scripts/menus/debug_menu"
--local steam_achievements = require"scripts/steam/achievements"

local game_manager = {}


--Quest Log Menu: name of sound to play for different new task status keywords
local QUEST_SOUNDS = {
    main_all_completed = "quest_complete",
    side_all_completed = "quest_complete",
    main_completed = "quest_complete",
    side_completed = "quest_complete",
    main_started = "quest_started",
    side_started = "quest_started",
    main_advanced = "quest_advance",
    side_advanced = "quest_advance",
    new_checkmark = "quest_subtask",
    progressed_quest_item = "quest_subtask",
    alternate_swap = "quest_subtask",
    forced_update = "quest_subtask",
    main_advanced_again = false, --don't play sound
    side_advanced_again = false, --don't play sound
}

-- Starts the game from the given savegame file,
-- initializing it if necessary.
function game_manager:create(file_name, overwrite_game)
  if overwrite_game then sol.game.delete(file_name) end
  local exists = sol.game.exists(file_name)
  local game = sol.game.load(file_name)
  if not exists then -- Initialize a new savegame.
    initial_game:initialize_new_savegame(game)
  end

  --set an empty array for holding foraged bushes
  game.foraged_bushes = {}

  --for the location banner on entering locations
  game.map_banner = map_banner

  --allow accessing world_map script from game
  game.world_map = world_map

  objectives_manager.create(game)


  local function check_for_sidequests_achievement()
    local completed_main, total_main = game.objectives:get_counts("main")
    local completed_side, total_side = game.objectives:get_counts("side")
    --print("Completed: ", completed_side, " / Total: ", total_side)
    --Account for the one branching quest
    if game:get_value("aster_murdered") then --You choose to kill Aster, therefore there is one less possible quest
      total_side = total_side - 1
      --print("Adjusted. Completed: ", completed_side, " / Total: ", total_side)
    end
    --print("Checking for sidequest completion")
    --print("Sidequests:", completed_side, "/", total_side)
    if completed_side >= total_side then
      --print"Completed all or more!"
      sol.achievements.unlock("ach_all_sidequests")
    end
  end

  game:register_event("on_started", function()
    --reset some values whenever game starts or restarts
    game_restart:reset_values(game)
    --Magic auto-refills
    game:start_magic_regen_timer()
    sol.achievements.update()
    check_for_sidequests_achievement()

  end)

  --***Initialize Stuff***
  button_inputs_manager:initialize(game)
  debug_keys_manager:initialize(game)
  gameover_and_respawn_manager:initialize(game)

  ----------------------------------------------
  --Define / redefine events--------------------

  function game:on_paused()
    if not sol.menu.is_started(pause_menu) and not (game:get_hero():get_state() == "frozen") then
      sol.menu.start(game, pause_menu)
    elseif not sol.menu.is_started(pause_menu) and (game:get_hero():get_state() == "frozen") then
      sol.menu.start(game, noninteractable_pause_menu)
    end
  end


  function game.objectives:on_quest_updated(status, dialog_id)
    local sound_name = QUEST_SOUNDS[status]
    if sound_name then sol.audio.play_sound(sound_name) end

    quest_update_icon:refresh_opacity()
    quest_update_icon:set_status(status)
    if not sol.menu.is_started(quest_update_icon) then
      sol.menu.start(game, quest_update_icon)
    end
    sol.timer.start(game, 100, function()
      if quest_update_icon:get_opacity() < 11 then
        sol.menu.stop(quest_update_icon)
      else
        quest_update_icon:reduce_opacity(10)
        return true
      end
    end)

    --Check if all quests are completed:
    if status == "main_completed" or status == "side_completed" or status == "main_all_completed" or status == "side_all_completed" then
      check_for_sidequests_achievement()
    end
  end

  function game:start_magic_regen_timer()
    sol.timer.start(game, 300, function()
      if not game:is_suspended() then
        game:add_magic(1)
      end
      return true
    end)
  end


  return game
end

return game_manager
