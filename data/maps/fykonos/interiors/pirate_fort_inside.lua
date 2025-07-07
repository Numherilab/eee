local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  map:set_doors_open"boss_door"

  if not game:get_value"fykonos_boomerang_pirate_defeated" then boomerang_pirate:set_enabled(true) end
  boomerang_pirate:set_life(25+10)
  boomerang_pirate:set_damage(6)
end)


function upstairs_switch:on_activated()
  map:focus_on(map:get_camera(), upstairs_door, function()
    map:open_doors"upstairs_door"
  end)
end

function boom_unblocker:on_activated()
  for wall in map:get_entities"boom_block" do
    wall:remove()
  end
end

function boomerang_pirate:on_dead()
  map:open_doors"downstairs_door"
end

function boss_sensor:on_activated()
  if not game:has_item"bow" then
    map:close_doors"boss_door"
    boss_sensor:remove()
  end
end

function stone_boss:on_dead()
  map:open_doors"boss_door"
end

