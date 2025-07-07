local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  if game:get_value("talked_to_jerah_in_the_grove") ~= true then jerah:set_enabled(false) end

end)


function olin:on_interaction()
  if game:get_value("have_juniper_key") == true then --if he's given you the key to the grove to find Jerah
    if game:get_value"talked_to_jerah_in_the_grove" then
      game:start_dialog"_yarrowmouth.npcs.tavern.Olin.4"
    else
      game:start_dialog("_yarrowmouth.npcs.tavern.Olin.3")
    end
  else

    if game:get_value("quest_spruce_head") == 2 then --if Spruce Head quest is on "Check with Distillery" step
      game:start_dialog("_yarrowmouth.npcs.tavern.Olin.2", function()
        game:set_value("have_juniper_key", true)
        game:set_value("possession_key_juniper_grove", 1)
        game:set_value("amount_key_juniper_grove", 1)
        game:set_value("quest_spruce_head", 3) --quest log
        if not game:get_value"quest_hourglass_fort" then
          game:set_value("quest_hourglass_fort", 0) --quest log
        end
      end)
    else
      game:start_dialog("_yarrowmouth.npcs.tavern.Olin.1")
    end

  end --end of has item function

end


function jerah:on_interaction()
  game:start_dialog("_yarrowmouth.npcs.tavern.jerah.3")
end


--Rohit - Meadery Quest
function rohit:on_interaction()
  local rdc = game:get_value("rohit_dialog_counter")
  if rdc == nil then
    game:start_dialog("_yarrowmouth.npcs.tavern.rohit.1", function(answer)
      if answer == 2 then
        game:start_dialog("_yarrowmouth.npcs.tavern.rohit.2", function()
          game:set_value("quest_briarwood_mushrooms", 0)
          game:set_value("you_got_mushroom_spot_key", true)
          game:set_value("possession_key_mushroom_spot", 1)
          game:set_value("rohit_dialog_counter", 1)
        end)
      end
    end)

  elseif rdc == 1 then
    game:start_dialog("_yarrowmouth.npcs.tavern.rohit.3")

  --if you've found the bait, but not the cabin
  elseif rdc == 2 then
    game:start_dialog("_yarrowmouth.npcs.tavern.rohit.4", function() game:add_money(65) end)
    game:set_value("rohit_dialog_counter", 3)

  elseif rdc == 3 then
    game:start_dialog("_yarrowmouth.npcs.tavern.rohit.5")

  elseif rdc == 4 then
    game:start_dialog("_yarrowmouth.npcs.tavern.rohit.6", function()
      game:set_value("quest_briarwood_mushrooms", 3) --quest log, go fight michael
      game:set_value("rohit_dialog_counter", 5)
      game:set_value("suspect_michael", true)
    end)

  elseif rdc == 5 then
    game:start_dialog("_yarrowmouth.npcs.tavern.rohit.7")

  elseif rdc == 6 then
    game:start_dialog("_yarrowmouth.npcs.tavern.rohit.8", function()
      game:set_value("quest_briarwood_mushrooms", 5) --quest log
      game:add_money(110)
      game:set_value("rohit_dialog_counter", 7)
      game:set_value("briarwood_distillery_quest_complete", true)
    end)

  elseif rdc == 7 then
    game:start_dialog("_yarrowmouth.npcs.tavern.rohit.9")

  end --end of rohit dialog counter if/then
end
