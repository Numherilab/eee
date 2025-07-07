-- Lua script of item flippers.
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

  -- Initialize the properties of your item here,
  -- like whether it can be saved, whether it has an amount
  -- and whether it can be assigned.
  item:set_savegame_variable("possession_flippers")
end)

item:register_event("on_variant_changed", function(self, variant)
  --the possession state of the flippers determines the hardcoded engine ability "swim"
  game:set_ability("swim", variant)
end)
