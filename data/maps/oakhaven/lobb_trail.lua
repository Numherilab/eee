local map = ...
local game = map:get_game()

function veilwood_door_switch:on_activated()
  map:open_doors"veilwood_door"
end