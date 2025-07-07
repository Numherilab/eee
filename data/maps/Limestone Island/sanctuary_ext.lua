-- Lua script of map Limestone Island/sanctuary_ext.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end
--[[
local function explode()
  local barrel_x, barrel_y, barrel_layer = explosive_barrel:get_position()
  explosive_barrel:set_enabled(false)
  map:create_explosion({
    layer = barrel_layer,
    x = barrel_x,
    y = barrel_y,
  })
end

function explosive_barrel:on_interaction_item(sword)
  explode()
end

function explosive_barrel:on_collision_fire()
  explode()
end
--]]