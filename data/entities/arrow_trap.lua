-- Lua script of custom entity arrow_trap.
-- This script is executed every time a custom entity with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local x, y, layer

-- Event called when the custom entity is initialized.
function entity:on_created()
  x, y, layer = entity:get_position()
end

function entity:shoot(direction)
  local dx = {[0] = 16, [1] = 0, [2] = -16, [3] = 0}
  local dy = {[0] = 0, [1] = -16, [2] = 0, [3] = 16}
  local arrow = map:create_enemy({
    x = x + dx[direction], y = y + dy[direction], layer = layer, direction = direction,
    breed = "misc/arrow_4",
  })
  arrow:set_damage(1)
  arrow:go(direction)
end