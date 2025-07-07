-- Lua script of map Yarrowmouth/caves/ghost_ship.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(2)
  sol.menu.start(map, lighting_effects)

  sol.achievements.unlock("ach_lighthouses")
end)

function boss_sensor:on_activated()
  boss_sensor:set_enabled(false)
  local x, y, layer = zephyrine:get_position()
  local effect = map:create_custom_entity{
    width = 16, height = 16,
    direction = 0, x = x, y = y+8, layer = layer, model = "ephemeral_effect", sprite = "entities/poof"
  }
  zephyrine:set_enabled(true)
end

function zephyrine:on_dead()
  local x, y, layer = zephyrines_tempest:get_position()
  local effect = map:create_custom_entity{
    width = 16, height = 16,
    direction = 0, x = x, y = y+8, layer = layer, model = "ephemeral_effect", sprite = "entities/poof"
  }
  zephyrines_tempest:set_enabled(true)
  leave_sensor:set_enabled()
end

function leave_sensor:on_activated()
  game:set_value("quest_lighthouses", 3)
end