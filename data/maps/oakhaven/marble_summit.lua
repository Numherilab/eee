-- Lua script of map oakhaven/marble_summit.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
  if game:get_value("quest_manna_oaks") then
    if game:get_value("quest_manna_oaks") == 0 then manna_oak_twig:set_enabled(true) end
    if game:get_value("quest_manna_oaks") >= 7 then manna_tree_door:set_enabled(false) end
    if game:get_value("quest_manna_oaks") >= 9 then manna_oak_leaves:set_enabled(true) end
  end
end)

function door_item_sensor:on_activated()
  if not game:has_item("heron_door_marble_summit") then
    game:get_item("heron_door_marble_summit"):set_variant(1)
    game:set_value("found_heron_door_marble_summit", 1) --TODO quest log issue #76
    game.objectives:force_update() --TODO quest log issue #70
  end
end

function no_hit_path_sensor:on_activated()
  game.cursed_marble_no_hit_check = true
end
