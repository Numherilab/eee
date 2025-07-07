-- Lua script of map Goatshead Island/poplar_forest.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

map:register_event("on_started", function()

end)

function weak_tree_enemy:on_disabled()
  fall_tree_1:set_enabled(true)
  fall_tree_2:set_enabled(true)
  fall_tree_3:set_enabled(true)
  fall_tree_4:set_enabled(true)
  
end