local item = ...
local game = item:get_game()

function item:on_started()
  local name = item:get_name():gsub("/", "_")
  item:set_savegame_variable("possession_" .. name)
end

function item:on_using()
  game:set_ability("lift", 1)
  game:set_ability("sword", 1)
  game:get_item("bow"):set_variant(1)
  game:get_item("bow"):add_amount(100)
  game:get_item("bow_warp"):set_variant(1)
  game:get_item("bow_fire"):set_variant(1)
  game:get_item("bow_bombs"):set_variant(1)
  game:get_item("ball_and_chain"):set_variant(1)
  game:get_item("bombs_counter_2"):set_variant(1)
  game:get_item("bombs_counter_2"):add_amount(100)
  game:get_item("boomerang"):set_variant(1)
  game:get_item("spear"):set_variant(1)
  game:get_item("barrier"):set_variant(1)
  game:get_item("crystal_spark"):set_variant(1)
  game:get_item("abyssal_flame"):set_variant(1)
  game:get_item("thunder_charm"):set_variant(1)
  game:get_item("leaf_tornado"):set_variant(1)
  game:get_item("gust"):set_variant(1)
  item:set_finished()
end
