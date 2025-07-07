require("scripts/multi_events")

local item = ...
local game = item:get_game()

local MAGIC_COST = 10

item:register_event("on_started", function(self)
  item:set_savegame_variable("possession_barrier")
  item:set_assignable(true)
end)

item:register_event("on_obtaining", function(self)
  game:set_ability("sword", 1)
end)

item:register_event("on_using", function(self)
  if game:get_magic() < MAGIC_COST then sol.audio.play_sound("no")
  else
    game:remove_magic(MAGIC_COST)
    local hero = game:get_hero()
    hero:freeze()
      hero:set_sword_sprite_id("hero/barrier")
      hero:unfreeze()
      hero:start_attack()
      sol.audio.play_sound("cane")
      hero:set_invincible(true, 600)
      local sprite = hero:get_sprite()
      local animation = sprite:get_animation()
      function sprite:on_animation_finished()
        hero:set_sword_sprite_id("hero/sword1")
      end
  end
  item:set_finished()
end)
