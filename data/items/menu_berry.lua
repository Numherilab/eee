require("scripts/multi_events")

local item = ...
local game = item:get_game()

-- Event called when the game is initialized.
item:register_event("on_started", function(self)
  item:set_savegame_variable("possession_menu_berry")
  item:set_assignable(true)
end)

-- Event called when the hero is using this item.
item:register_event("on_using", function(self)
  game:add_life(2)
  sol.audio.play_sound("heart")
  print("used menu berry")
  item:set_finished()
end)

item:register_event("on_obtained", function(self)
  game:set_item_assigned(1, item)
end)
