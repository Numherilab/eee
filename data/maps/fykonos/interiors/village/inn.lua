local map = ...
local game = map:get_game()


function innkeeper:on_interaction()
    game:start_dialog("_fykonos.npcs.village.inkkeper", function()
        require("scripts/shops/inn"):start()
    end)
end

function door_sensor:on_activated()
  map:set_doors_open"upstairs_door"
end
