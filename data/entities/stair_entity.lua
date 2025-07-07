--[[
Staircase Entity
To replace the built-in engine stairs, which are inflexible.
Directions:
At the edge of a higher layer and a lower layer where you want a staircase, 

--]]

--NOTE: Not sure if I finished this, it might do nothing

local entity = ...
local game = entity:get_game()
local map = entity:get_map()
--direction is which direction the higher layer is from the lower layer.
--So where a higher layer is north of a lower layer, the entities direction would be "up"
local stair_direction
local lower_layer
local upper_layer
local width
local height

function entity:on_created()
  upper_layer = entity:get_layer()
  lower_layer = upper_layer - 1
  direction = entity:get_direction()
  entity:set_traversable_by("hero")
  entity:set_traversable_by("npc")
  --TODO: allow entity properties to dictate what kind of entities may use the stairs. In particular, enemies.
  width, height = entity:get_size()
  entity:set_origin(width()/2, height() - 3)
  
  
end
