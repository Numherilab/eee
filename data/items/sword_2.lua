require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_started", function(self)
  item:set_savegame_variable("possession_sword_2_test")
  item:set_assignable(true)
end)

item:register_event("on_obtaining", function(self)
  game:set_ability("sword", 1)
end)

item:register_event("on_using", function(self)
  local hero = game:get_hero()
  hero:set_sword_sprite_id("hero/spear")
  hero:unfreeze()
  hero:start_attack()
  sol.timer.start(game, 240, function() hero:set_sword_sprite_id("hero/sword1") end)
  item:set_finished()
end)


--  hero:set_sword_sprite_id("hero/sword2")
--  hero:set_sword_sprite_id("hero/sword1")
