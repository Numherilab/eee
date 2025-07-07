require("scripts/multi_events")

local item = ...
local game = item:get_game()

-- Event called when the game is initialized.
item:register_event("on_started", function(self)
  item:set_savegame_variable("possession_tornado_dash")
  item:set_assignable(true)
end)

-- Event called when the hero is using this item.
item:register_event("on_using", function(self)
  local hero = game:get_hero()
--  sol.audio.play_sound("cane")
    hero:start_running()
  item:set_finished()
end)
