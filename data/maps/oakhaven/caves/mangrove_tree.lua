local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  if game:has_item("sword_of_the_sea_king") then
    sword_tile:set_enabled(false)
    sword:set_enabled(false)
  else
    hazel:set_enabled()
  end
end)


function sword:on_interaction()
  sword_tile:set_enabled(false)
  map:get_hero():start_treasure("sword_of_the_sea_king")
  sword:set_enabled(false)
end
