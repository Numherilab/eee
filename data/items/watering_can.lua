-- Lua script of item watering_can.
-- This script is executed only once for the whole game.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest


require("scripts/multi_events")

local item = ...
local game = item:get_game()

-- Event called when the game is initialized.
item:register_event("on_started", function(self)

  self:set_savegame_variable("possession_watering_can")
  self:set_sound_when_picked(nil)
end)

-- Event called when the hero is using this item.
item:register_event("on_using", function(self)

  -- Define here what happens when using this item
  -- and call item:set_finished() to release the hero when you have finished.
  item:set_finished()
end)

-- Event called when a pickable treasure representing this item
-- is created on the map.
item:register_event("on_pickable_created", function(self, pickable)

  -- You can set a particular movement here if you don't like the default one.
end)
