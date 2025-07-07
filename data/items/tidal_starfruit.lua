require("scripts/multi_events")

local item = ...
local game = item:get_game()

-- Event called when the game is initialized.
item:register_event("on_created", function(self)
  item:set_savegame_variable("possession_tidal_starfruit")
  -- Initialize the properties of your item here,
  -- like whether it can be saved, whether it has an amount
  -- and whether it can be assigned.
end)

-- Event called when a pickable treasure representing this item
-- is created on the map.
item:register_event("on_pickable_created", function(self, pickable)

  -- You can set a particular movement here if you don't like the default one.
end)

item:register_event("on_obtained", function(self)
  game:set_value("quest_tidal_starfruit", 2)
end)
