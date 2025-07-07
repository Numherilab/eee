-- Lua script of map Yarrowmouth/juniper_grove.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  map:cloud_overlay()
  if game:get_value("talked_to_jerah_in_the_grove") == true then jerah:set_enabled(false) end

  if game:get_value("juniper_grove_fiend") == nil then
    for entity in map:get_entities("secondary_enemy") do
      entity:set_enabled(false)
    end
  end

end)

--[[
function leftkeysensor:on_activated()
  if game:get_value("juniper_grove_fiend") ~= nil and game:has_item("juniper_grove_key") ~= true then
    game:start_dialog("_game.left_important_item")
    local m = sol.movement.create("path")
    local hero = map:get_hero()
    m:set_path{2,2,}
    m:start(hero)
  end
end
--]]

function jerah:on_interaction()
  if game:get_value("talked_to_jerah_in_the_grove") == true then
    game:start_dialog("_yarrowmouth.npcs.tavern.jerah.2")
  else
    game:start_dialog("_yarrowmouth.npcs.tavern.jerah.1", function()
      game:set_value("talked_to_jerah_in_the_grove", true)
      game:set_value("quest_log_a", "a6")
      if game:get_value("quest_hourglass_fort") == 0 then
        game:set_value("quest_hourglass_fort", 1) --quest log
      end
    end)
  end
end

function raft_sensor_a:on_activated()
  raft_sensor_a:remove()
  sol.timer.start(map, 1000, function()
    map:open_doors("raft_gate")
    raft_b:remove()
    raft_sensor_b:remove()
  end)
end

function raft_sensor_b:on_activated()
  raft_sensor_b:remove()
  sol.timer.start(map, 500, function()
    map:open_doors("raft_gate")
    raft_a:remove()
    raft_sensor_a:remove()
  end)
end
