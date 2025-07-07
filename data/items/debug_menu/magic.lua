local item = ...
local game = item:get_game()

function item:on_started()
  local name = item:get_name():gsub("/", "_")
  item:set_savegame_variable("possession_" .. name)
end

function item:on_using()
  game:set_magic(game:get_max_magic())
  item:set_finished()
end
