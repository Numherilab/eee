-- Lua script of map ballast_harbor/ballast_harbor.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()
local dropoff_workers_dialog_index = 1

map:register_event("on_started", function()
  for person in map:get_entities"wandering_person" do
    local m = sol.movement.create"random_path"
    m:set_speed(15)
    m:start(person)
  end

  if hero:get_position() == from_back_alley_cave:get_position() then
    destroyable_fence:set_enabled(false)
  end
  if game:get_value("pirate_council_door_state") ~= nil then pirate_council_door:set_enabled(false) end
  if game:get_value("oakhaven_port_bridge_unblocked") then bomb_sale:set_enabed(false) end
  if game:get_value("talked_to_hornigold_in_ballast_harbor") then
    hornigold:set_enabled(false)
    hornigold_sensor:set_enabled(false)
  end
  --Ship dropping off stuff for Pirate Vault
  if game:get_value("ballast_harbor_dropoff_guys_in_port") then
    for entity in map:get_entities("dropoff_") do
      entity:set_enabled(true)
      inviting_barrel:set_enabled(true)
    end
  end
end)

---NPC INTERACTIONS
--shop
function market_shop:on_interaction()
  game:start_dialog("_ballast_harbor.npcs.market_people.shop", function()
    local shop_menu = require("scripts/shops/shop_menu")
    shop_menu:initialize(game)
    sol.menu.start(map, shop_menu)
  end)
end

--buyer
function buyer_guy:on_interaction()
  game:start_dialog("_generic_dialogs.buyer_guy.1", function()
    local sell_menu = require("scripts/shops/sell_menu")
    sell_menu:initialize(game)
    sol.menu.start(map, sell_menu)
  end)
end

--blacksmith
local smith_shop = require("scripts/shops/blacksmith")
function blacksmith:on_interaction()
  smith_shop:open_shop(game)
end --blacksmith interaction end

--cargo carrier guys:
for npc in map:get_entities("dropoff_npc") do
  function npc:on_interaction()
    if dropoff_workers_dialog_index == 1 then
      game:start_dialog("_ballast_harbor.npcs.dropoff_guys.2")
    elseif dropoff_workers_dialog_index == 2 then
      game:start_dialog("_ballast_harbor.npcs.dropoff_guys.3")
    elseif dropoff_workers_dialog_index == 3 then
      game:start_dialog("_ballast_harbor.npcs.dropoff_guys.1")
    end
    dropoff_workers_dialog_index = dropoff_workers_dialog_index + 1
    if dropoff_workers_dialog_index == 4 then dropoff_workers_dialog_index = 1 end
  end  
end

--inviting barrel
function inviting_barrel:on_interaction()
  game:start_dialog("_ballast_harbor.observations.inviting_barrel", function(answer)
    if answer == 2 then
      game:set_value("quest_kelpton", 2) --quest log
      game:set_value("ballast_harbor_dropoff_guys_in_port", false)
      hero:teleport("ballast_harbor/pirate_vault", "from_smuggled_in")
    end
  end)
end



---------Cutscene-----------
function hornigold_sensor:on_activated()
  hero:freeze()
  local m1 = sol.movement.create("path")
  m1:set_path{6,6,6,6,6,6,6,6,0,0,0,0,0,0,0,0}
  m1:set_speed(60)
  m1:set_ignore_obstacles(true)
  m1:start(hornigold, function()
    game:start_dialog("_ballast_harbor.npcs.hornigold.1", function()
      m1:set_speed(70)
      m1:set_path{0,0,0,0,0,0,0,0,0,0,0,0,0,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6}
      hero:set_direction(0)
      m1:start(hornigold, function()
        game:set_value("talked_to_hornigold_in_ballast_harbor", true)
        hero:unfreeze()
        hornigold:set_enabled(false)
        hornigold_sensor:set_enabled(false)
      end)
    end) --end of dialog callback
  end) --end of m1 callback
end

