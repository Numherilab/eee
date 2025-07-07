local item = ...
local game = item:get_game()

function item:on_started()
  local name = item:get_name():gsub("/", "_")
  item:set_savegame_variable("possession_" .. name)
end

function item:on_using()
  local hero = game:get_hero()
  sol.menu.stop(require"scripts/menus/debug_menu")
  hero:teleport"debug_room"
  item:set_finished()
end
