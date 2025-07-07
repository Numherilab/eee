-- Lua script of custom entity warp_block.
-- This script is executed every time a custom entity with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local entity = ...
local game = entity:get_game()
local map = entity:get_map()

-- Event called when the custom entity is initialized.
function entity:on_created()
  entity:set_traversable_by(false)
  entity:set_traversable_by("custom_entity", true)
  entity:set_traversable_by("hero", entity.overlaps)
  entity:set_traversable_by("enemy", entity.overlaps)
  entity:set_drawn_in_y_order(true)

  --fall into water animation
  sol.timer.start(entity, 100, function()
    local x, y, z = entity:get_position()
    if map:get_ground(x, y, z) == "deep_water" then
      sol.audio.play_sound"splash"
      map:create_custom_entity{
        x=x, y=y, layer=z, direction=0, width=16, height=16, model="ephemeral_effect",
        sprite="entities/splash"
      }
      entity:remove()
    else
      return true
    end
  end)
end
