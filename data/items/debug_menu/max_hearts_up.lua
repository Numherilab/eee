local item = ...
local game = item:get_game()

function item:on_started()
  local name = item:get_name():gsub("/", "_")
  item:set_savegame_variable("possession_" .. name)
end

function item:on_using()
  game:set_max_life(game:get_max_life() + 2)
  game:set_life(game:get_max_life())
  item:set_finished()
end
