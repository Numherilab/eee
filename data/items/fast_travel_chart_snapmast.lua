local item = ...
local game = item:get_game()

item:register_event("on_created", function(self)
  item:set_savegame_variable("fast_travel_chart_snapmast")
end)

item:register_event("on_obtained", function(self)
  game.world_map:set_map_visible("snapmast_reef/landing")
end)
