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
      if hero:get_state() == "back to solid ground" then return end
      sinking = true
      sprite:set_animation("destroy", function() entity:destroy() end)
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





--Here's the old leaf pile script:
--I replaced it with the collapsing floor entity script, which I think should work better in every
--situation. However, if it causes bugs, here's the old script:


--[[ Leaf pile script- modeled after the leaves in Zelda: Oracle of Seasons
-- 
-- Requires the muti-event script for full functionality.
-- which can be found here; 
-- 
-- This script is a custom entity script and provides the functions:
-- custom_entity:keep_existing() which tells the script to respawn the
-- leaves after being destoryed.
-- 
-- custom_entity:get_value() which will return the value of where this
-- entity's destoryed mem state is stored in the save data.

-- Made by Max Mraz, based off the Rock Stack script by yoshimario2000.

 
local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local hero = entity:get_game():get_hero()
local name = entity:get_name()
local collapsing = false


-- Event called when the custom entity is initialized.
function entity:on_created()
  entity:set_modified_ground("traversable")

  end


local function destroy_self()
  -- If your sprite has a diffrent animation for being destoryed, change the string "destroy"  into that animation id.
  entity:get_sprite():set_animation("destroy",
  function()
    entity:set_modified_ground("empty")
    entity:set_enabled(false)
  end)
end


map:register_event("on_update", function()
  if map:has_entity(name) then
    if entity:overlaps(hero) and collapsing == false and game:get_value("hero_dashing") == false then
    collapsing = true
    sol.timer.start(200, destroy_self)
    end
  end
end)

--]]
