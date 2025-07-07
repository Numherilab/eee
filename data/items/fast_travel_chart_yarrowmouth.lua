local item = ...
local game = item:get_game()

item:register_event("on_created", function(self)
  item:set_savegame_variable("fast_travel_chart_yarrowmouth")
end)

item:register_event("on_obtained", function(self)
  game.world_map:set_map_visible("Yarrowmouth/yarrowmouth_village")
end)
