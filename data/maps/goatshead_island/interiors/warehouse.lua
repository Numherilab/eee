-- Lua script of map goatshead_island/interiors/warehouse.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

function lever_switch:on_activated()
  sol.audio.play_sound("switch")
  sol.audio.play_sound("hero_pushes")
  for entity in map:get_entities("hook") do
    local m = sol.movement.create("path")
    m:set_path{0,0}
    m:set_ignore_obstacles(true)
    m:start(entity)
  end
end