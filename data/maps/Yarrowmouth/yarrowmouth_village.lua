local map = ...
local game = map:get_game()
local shop = require("scripts/shops/blacksmith")


-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  map:cloud_overlay()
  if game:get_value("dream_cannons_defeated") == true then carlov:set_enabled(false) end
  if game:get_value("yarrowmouth_bird_temple_door_opened") == true then bird_repaired:set_enabled(true) end

  for goat in map:get_entities"goat" do
    local gm=sol.movement.create("random")
    gm:set_speed(10)
    gm:start(goat)
  end

end)


function goat_3:on_interaction()
  sol.audio.play_sound"goat"
end


function map:test_m()
  local x,y,z = hero:get_position()
  local entity_1 = map:create_custom_entity{
    x=x,y=y,layer=z,width=16,height=16,direction=0,sprite="enemies/misc/spore"
  }
  local entity_2 = map:create_custom_entity{
    x=x,y=y,layer=z,width=16,height=16,direction=0,sprite="enemies/misc/spore"
  }
  local m = sol.movement.create"straight"
  m:set_max_distance(24)
  m:set_speed(100)
  m:start(entity_2)
  m:set_speed(m:get_speed() - 10)
  sol.timer.start(map, 1000, function()
    m:set_speed(m:get_speed() - 10)
    return m:get_speed() >40
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
            game:start_dialog("_yarrowmouth.npcs.mera.4", function() game:set_value("quest_iron_pine_cone", 3) end)
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