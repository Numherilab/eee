local map = ...
local game = map:get_game()


map:register_event("on_started", function()
  map:cloud_overlay("fog/clouds_2.png")
  if game:get_value("sinking_palace_lighthouse_lit") then
    for e in map:get_entities"lighthouse_light" do
      e:set_enabled(true)
    end
  end
end)

function gate_switch:on_activated()
  sol.audio.play_sound"switch"
  map:open_doors("gate")
end
