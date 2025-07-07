-- Lua script of custom entity collapsing_floor.
-- This script is executed every time a custom entity with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local hero = map:get_hero()
local sprite = entity:get_sprite()
local sinking

function entity:on_created()
  sinking = false
  entity:set_modified_ground("traversable")
  entity:set_traversable_by(true)
  entity:can_traverse_ground("deep_water")
  entity:can_traverse_ground("shallow_water")
  entity:add_collision_test("overlapping", function(entity, other_entity)
    if other_entity:get_type() == "hero" and sinking == false then
      sinking = true
      if hero:get_state() == "back to solid ground" then return end
      if sprite:has_animation"shaking" then sprite:set_animation"shaking" end
      sol.timer.start(map, entity:get_property("collapse_delay") or 800, function()
        sprite:set_animation("destroy", function() entity:destroy() end)
      end)
    end
  end)
end


function entity:destroy()
  entity:set_modified_ground("empty")
  if entity:get_property("can_respawn") then
    local time = entity:get_property("respawn_delay") or 5000
    sol.timer.start(entity, time, function()
      sinking = false
      entity:respawn()
    end)
  else
    entity:set_enabled(false)
  end
end


function entity:respawn()
  entity:set_enabled(true)
  entity:set_modified_ground("traversable")
  if sprite:has_animation("respawn") then
    sprite:set_animation("respawn", function() sprite:set_animation("stopped") end)
  else
    sprite:set_animation("stopped")
  end
end

