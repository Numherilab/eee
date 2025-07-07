-- Lua script of map oakhaven/eastoak.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  guard_2:set_enabled(false)
  if game:get_value("spiked_crow_ale") then guard_1:set_enabled(false) guard_2:set_enabled(true) end
  if game:get_value("fort_crow_front_door_open") == true then map:set_doors_open("front_door") end
  if game:get_value("thyme_defeated") == true then guard_2:set_enabled(false) end

  if game:get_value("quest_pirate_fort") == 4 then morus:set_enabled(true) end

  if game:get_value("barbell_brutes_defeated") == true then
    vice_captain:set_enabled(true) wine:set_enabled(true)
  end

--moved to westoak in new overworld
  if game:get_value("quest_bomb_shop") ~= nil and game:get_value("quest_bomb_shop") > 1 then
    bomb_shop_intern:set_enabled(false)
  end
--moved to port in new overworld
  if game:get_value("quest_bomb_arrows") and game:get_value("quest_bomb_arrows") >= 2 then
    gallery_door:set_enabled(false)
    gallery_door_npc:set_enabled(false)
  end

  local m1 = sol.movement.create("path")
  m1:set_path{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,6,6,6,6,6,6,6,6,6,6,
  4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,2,2,2,2,2,2,2,2,2,2}
  m1:set_speed(40)
  m1:set_loop(true)
  m1:set_ignore_obstacles(true)
  m1:start(circulate_guy)
  circulate_guy:set_traversable(true)
end)


function vice_captain:on_interaction()
  game:start_dialog("_oakhaven.npcs.vice_captain.1")
end

function enable_sensor_sensor:on_activated()
  map:get_entity("^map_banner_sensor"):set_enabled(true)
  sol.timer.start(map, 1000, function() map:get_entity("^map_banner_sensor"):set_enabled(false) end)
  enable_sensor_sensor:set_enabled(false)
end


function morus:on_interaction()
  game:start_dialog("_oakhaven.npcs.morus.fort.1", function()
    local m = sol.movement.create("path")
    m:set_path{2,2,2,2,2,2,2,2}
    m:set_speed(60)
    m:start(morus, function() morus:remove() end)
    game:set_value("quest_pirate_fort", 5)
    game:set_value("fort_crow_interior_morus_counter", 1)
  end)
end

--moved to port
function gallery_door_npc:on_interaction()
  if game:get_value("quest_bomb_arrows") and game:get_value("quest_bomb_arrows") == 1 then
    game:start_dialog("_oakhaven.npcs.shipyard.gallery_door2", function()
      gallery_door:set_enabled(false)
      gallery_door_npc:set_enabled(false)
      game:set_value("quest_bomb_arrows", 2)
    end)
  else
    game:start_dialog("_oakhaven.npcs.shipyard.gallery_door1")
  end
end

--moved to westoak
function bomb_shop_intern:on_interaction()
  local quest_value = game:get_value("quest_bomb_shop")
  if quest_value == nil then
    game:start_dialog("_oakhaven.npcs.bomb_shop.intern.1", function() game:set_value("quest_bomb_shop", 0) end)

  elseif quest_value  == 0 then
    game:start_dialog("_oakhaven.npcs.bomb_shop.intern.1")

  elseif quest_value == 1 then
    game:start_dialog("_oakhaven.npcs.bomb_shop.intern.2", function()
      game:set_value("quest_bomb_shop", 2)
      local m = sol.movement.create("path")
      m:set_path{4,4}
      m:start(bomb_shop_intern)
    end)

  elseif quest_value == 2 then
    game:start_dialog("_oakhaven.npcs.bomb_shop.intern.2")

  end
end

