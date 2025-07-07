local map = ...
local game = map:get_game()

map:register_event("on_started", function()


end)

for ear in map:get_entities("goat_ear") do
  function ear:on_interaction()
    sol.audio.play_sound("switch_2")
    goat_snout_open:set_enabled(true)
    goat_snout_closed:set_enabled(false)
    goat_ear:set_enabled(false)
  end
end

function gerald:on_interaction()
  if game:get_value("west_goat_cracked_block_11") ~= nil then
    game:start_dialog("_goatshead.npcs.overworld.bomb_rocks_guy_2")
  else
    game:start_dialog("_goatshead.npcs.overworld.bomb_rocks_guy_1")
  end
end