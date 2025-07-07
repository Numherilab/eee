--Ancient Grove Puzzlewood

local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  if game:get_value("ancient_grove_puzzlewood_activated") then
    glow:set_enabled(true)
    revenant:set_enabled(false)
  end
end)

function revenant:on_dead()
  map:get_camera():shake()
  sol.audio.play_sound"secret"
fx:get_sprite():flash()
  glow:set_enabled(true)
  game:set_value("ancient_grove_puzzlewood_activated", true)
  if not game:get_value("quest_ancient_groves") then game:set_value("quest_ancient_groves", 0) end
  local amount = game:get_value("ancient_groves_activated") or 0
  amount = amount + 1
  game:set_value("ancient_groves_activated", amount)
  if amount == 3 then
    game:set_value("quest_ancient_groves", 1)
  end
end