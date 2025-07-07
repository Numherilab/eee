local map = ...
local game = map:get_game()


map:register_event("on_started", function()
  if game:get_value("hourglass_fort_read_letter") == true then eudicot:set_enabled(false) end

end)



function bridge_switch_1:on_activated()
  map:open_doors("central_door")
end
