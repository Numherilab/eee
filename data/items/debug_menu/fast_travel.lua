local item = ...
local game = item:get_game()

function item:on_started()
  local name = item:get_name():gsub("/", "_")
  item:set_savegame_variable("possession_" .. name)
end

function item:on_using()
  local fast_travel = require"scripts/menus/fast_travel"
  local map = game:get_map()
  local hero = game:get_hero()
  game.world_map:show_all()
  sol.timer.start(game, 200, function()
    sol.menu.stop(require"scripts/menus/debug_menu")
    fast_travel:unlock_all_ports()
    sol.menu.start(map, fast_travel)
    item:set_finished()
  end)
end
