require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_created", function(self)

  item:set_savegame_variable("possession_basswood_tavern_key")
--  item:set_sound_when_brandished(nil)
--  item:set_sound_when_picked(nil)
--  item:set_shadow(nil)
end)
