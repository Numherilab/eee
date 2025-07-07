local foraging_manager = {}

local RESPAWN_TIME = 10 * 1000 * 60 --the first number is minutes

local foraging_treasures = {
  "ghost_orchid",
  "firethorn_berries",
  "arrow",
  "apples",
  "kingscrown",
  "burdock",
  "chamomile",
  "berries",
  "lavendar",
  "witch_hazel"
}

--game.foraged_bushes[map][x..","..y..","..z] = timer
--this is just an example of how the table is laid out, so I can understand what I'm doing
local example_table = {
  map = {
    coord_a = {x = "x", y = "y", timer = "timer"},
    coord_b = {x = "x", y = "y", timer = "timer"},
  },
  map
}


function foraging_manager:remove_picked_plants(map)
  local game = map:get_game()

  for bush in map:get_entities_by_type("destructible") do
    local bx,by,bz = bush:get_position()
    if game.foraged_bushes[map:get_id()] then
      for coord, values in pairs(game.foraged_bushes[map:get_id()]) do
        if values.x == bx and values.y == by and values.z == bz then
          bush:remove()
        end
      end
    end
  end
end


function foraging_manager:process_cut_bush(bush)
  for k,name in pairs(foraging_treasures) do
    if name == bush:get_treasure() then
      local map = bush:get_map()
      local x,y,z = bush:get_position()
      local coordinates = x..","..y..","..z
      local game = map:get_game()
      if not game.foraged_bushes[map:get_id()] then
        game.foraged_bushes[map:get_id()] = {}
      end
      game.foraged_bushes[map:get_id()][coordinates] = {}
      game.foraged_bushes[map:get_id()][coordinates] = {x = x ,y = y, z = z}
      game.foraged_bushes[map:get_id()][coordinates].timer = sol.timer.start(game, RESPAWN_TIME, function()
        game.foraged_bushes[map:get_id()][coordinates] = nil
      end)
    end
  end
end


return foraging_manager