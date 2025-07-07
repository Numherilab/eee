local map = ...
local game = map:get_game()

--movement to get kelpton out of the way
local m = sol.movement.create("path")
m:set_path{0,0}
m:set_speed(70)


map:register_event("on_started", function()
  if game:has_item("charts")==true then kelpton:set_enabled(false) else kelpton_2:set_enabled(false) end

end)


function kelpton:on_interaction()
  if game:get_value("have_ballast_harbor_clue") ~= true then
    game:start_dialog("_ballast_harbor.npcs.kelpton.0")

  elseif game:get_value("kelpton_convo_counter") == nil then
    game:start_dialog("_ballast_harbor.npcs.kelpton.1", function()
      game:set_value("quest_kelpton", 1) --quest log
      game:set_value("ballast_harbor_dropoff_guys_in_port", true)
      game:set_value("kelpton_convo_counter", 1)
    end)

  elseif game:get_value("kelpton_convo_counter") == 1 then
    game:start_dialog("_ballast_harbor.npcs.kelpton.2")

  end
end

function kelpton_2:on_interaction()
  --talked_to_kelpton_2 is true once you get the key
  if game:get_value("talked_to_kelpton_2") ~= true then

    --if you have the charts, and you've already spoken with Kelpton. You haven't skipped anything.
    if game:get_value("kelpton_convo_counter") ~= nil then
      game:start_dialog("_ballast_harbor.npcs.kelpton.3", function()
--        m:start(kelpton_2)
        game:get_hero():start_treasure("key_kingsdown", 1)
        game:set_value("talked_to_kelpton_2", true)
        game:set_value("quest_kelpton", 4) --quest log
      end)

    else --you haven't talked to kelpton, but you got the charts, you skipped the beginning of the quest
      game:start_dialog("_ballast_harbor.npcs.kelpton.5", function()
--        m:start(kelpton_2)
        game:get_hero():start_treasure("key_kingsdown", 1)
        game:set_value("talked_to_kelpton_2", true)
        game:set_value("quest_kelpton", 4) --quest log
      end)
    end

  else --you've already received the key
    game:start_dialog("_ballast_harbor.npcs.kelpton.4")
  end
end
