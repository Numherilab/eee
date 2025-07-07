-- Lua script of map goatshead_island/crabhook_village.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  if game:get_value("crabhook_armor_purchased") then armor_upgrade:set_enabled(false) end
end)

----------SHOP---------



function armor_sale:on_interaction()
  if game:get_value("crabhook_armor_purchased") == nil then
    game:start_dialog("_goatshead.npcs.crabhook.armor_saleslady.1", function(answer)
      if answer == 1 then
        if game:get_money() < 150 then
          game:start_dialog("_game.insufficient_funds")
          return
        end
        map:get_hero():start_treasure("armor_upgrade_1")
        game:set_value("crabhook_armor_purchased", true)
        game:remove_money(150)
        armor_upgrade:set_enabled(false)
      end
    end)
  else
    game:start_dialog("_goatshead.npcs.crabhook.armor_saleslady.2")
  end
end


function fish_salesman:on_interaction()
  if game:get_value("phantom_squid_quest_completed") ~= true then
    game:start_dialog("_goatshead.npcs.crabhook.market_people.1")
  else
    game:start_dialog("_goatshead.npcs.crabhook.market_people.2")
  end
end

function old_fire_lady:on_interaction()
  if game:get_value("phantom_squid_quest_completed") ~= true then
    game:start_dialog("_goatshead.npcs.crabhook.market_people.3")
  else
    game:start_dialog("_goatshead.npcs.crabhook.market_people.4")
  end
end

--fisherman who tells you to talk to Arni
function fishin_guy:on_interaction()
  if game:get_value("looking_for_crabhook_monster") ~= true then
    game:start_dialog("_goatshead.npcs.crabhook.market_people.8")
  else
    if game:get_value("poplar_coast_menace_state") ~= nil then
      game:start_dialog("_goatshead.npcs.crabhook.market_people.10")
    else
      game:start_dialog("_goatshead.npcs.crabhook.market_people.9")
      game:set_value("quest_crabhook_shoal_monster", 1) --quest log
    end
  end
end

function boat_sensor:on_activated()
  if game:get_value("quest_dusit") then
    game:start_dialog("_goatshead.npcs.crabhook.dusit.go_to_brickenbranch", function(answer)
      if answer == 3 then
        game:get_hero():teleport("goatshead_island/brickabranch_island", "landing")
      end
    end)
  end
end

function ballast_man:on_interaction()
  game:start_dialog"_goatshead.npcs.crabhook.market_people.ballast_man_1"
  game.world_map:set_map_visible("ballast_harbor/ballast_harbor") --make spruce head visible
end

