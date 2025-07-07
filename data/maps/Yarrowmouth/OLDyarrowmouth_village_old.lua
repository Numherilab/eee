-- Lua script of map Yarrowmouth/yarrowmouth_village.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local shop = require("scripts/shops/blacksmith")


-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  goatshead_teletransport:set_enabled(false)
  oakhaven_teletransport:set_enabled(false)
  to_limestone:set_enabled(false)
  if game:get_value("dream_cannons_defeated") == true then carlov:set_enabled(false) end
  if game:get_value("yarrowmouth_bird_temple_door_opened") == true then bird_repaired:set_enabled(true) end

  local gm=sol.movement.create("random")
  gm:set_speed(10)
  gm:start(goat)

end)


function goatshead_ferry:on_interaction()
  game:start_dialog("_ferries.goatshead", function(answer)
    if answer == 3 then
      if game:get_money() >9 then
        game:remove_money(10)
        hero:teleport("goatshead_island/goatshead_harbor", "ferry_landing")
      else
        game:start_dialog("_game.insufficient_funds")
      end
    end
  end)
end

function oakhaven_ferry:on_interaction()
  game:start_dialog("_ferries.oakhaven", function(answer)
    if answer == 3 then
      if game:get_money() >9 then
        game:remove_money(10)
        hero:teleport("oakhaven/port", "from_ferry")
      else
        game:start_dialog("_game.insufficient_funds")
      end
    end
  end)
end

function broken_bird_statue:on_interaction()
  if game:has_item("stone_beak") == true then
    game:start_dialog("_yarrowmouth.observations.broken_bird.2", function(answer)
      if answer == 3 then
        game:set_value("quest_stone_beak", 1)
        bird_repaired:set_enabled(true)
        map:open_doors("bird_beak_door")
        sol.audio.play_sound("secret")
        game:set_value("yarrowmouth_bird_temple_door_opened", true)
      end
    end)
  else
    game:start_dialog("_yarrowmouth.observations.broken_bird.1")
  end
end


--armorer pinecone quest
function mera:on_interaction()
  if game:get_value("yarrow_mera_armor_obtained") ~= true then --if you don't already have the armor
  --if you have a pinecone
    if game:has_item("iron_pinecone") == true then
      game:start_dialog("_yarrowmouth.npcs.mera.3", function(answer)

        if answer == 2 then
          if game:get_money() >49 then
            game:remove_money(50)
            game:start_dialog("_yarrowmouth.npcs.mera.4", function() game:set_value("quest_iron_pine_cone", 3) end) --ql
            game:set_value("defense", game:get_value("defense") +2)
            game:set_value("yarrow_mera_armor_obtained", true)

          else
            game:start_dialog("_game.insufficient_funds")
            if game:get_value("quest_iron_pine_cone") == 1 then
              game:set_value("quest_iron_pine_cone", 2) --ql
            end
          end --end money check
        end --end of answer check

      end) --end of mera.3 dialog

    else --if you don't have the pinecone yet
      game:start_dialog("_yarrowmouth.npcs.mera.1", function(answer)
        game:start_dialog("_yarrowmouth.npcs.mera.2", function() game:set_value("quest_iron_pine_cone", 0) end) --ql
      end) --end of how you answer if you want armor
    end--end of if you have pinecone or not
  else --if you have already gotten the armor
    game:start_dialog("_yarrowmouth.npcs.mera.5")
  end
end



function blacksmith:on_interaction()
  shop:open_shop(game)
end --blacksmith interaction end