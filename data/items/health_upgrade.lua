require("scripts/multi_events")

local item = ...
local game = item:get_game()
local amount_of_health = 0


item:register_event("on_created", function(self)
  self:set_can_disappear(false)
  self:set_brandish_when_picked(true)
  item:set_sound_when_brandished("piece_of_heart")
  item:set_sound_when_picked("piece_of_heart")
end)

item:register_event("on_obtaining", function(self, variant, savegame_variable)
  local volume = sol.audio.get_music_volume()
  sol.audio.set_music_volume(volume - 40)
  sol.timer.start(game, 100, function() sol.audio.set_music_volume(volume) end)
  game:add_max_life(2)
  game:add_max_life(variant-1)
  game:set_life(game:get_max_life())

end)
