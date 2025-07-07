require("scripts/multi_events")

local item = ...
local game = item:get_game()

local MAGIC_COST = 1

-- Event called when the game is initialized.
item:register_event("on_started", function(self)
  item:set_savegame_variable("possession_cyclone_charm")
  item:set_assignable(true)
end)

-- Event called when the hero is using this item.
--[[
item:register_event("on_using", function(self)
  local hero = game:get_hero()
  if game:get_magic() < MAGIC_COST then sol.audio.play_sound("no")
  else
    game:remove_magic(MAGIC_COST)
    game:set_ability("sword_knowledge", 1)
    hero:start_attack_loading(0)
  item:set_finished()
end)
--]]
--
item:register_event("on_using", function(self)
  item:set_finished()
end)
--]]
