local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  if game:get_value("quest_manna_oaks") and game:get_value("quest_manna_oaks") > 5 and game:get_value("quest_manna_oaks") <9 then
    lamia:set_enabled(false)
  end
end)

function lamia:on_interaction()
  --if you aren't yet on this phase of her quest:
  if game:get_value("quest_manna_oaks") == nil or game:get_value("quest_manna_oaks") < 3 then
    game:start_dialog("_oakhaven.npcs.ivystump.lamia.1")

  --if Hazel has just sent you to talk to Lamia
  elseif game:get_value("quest_manna_oaks") == 3 or game:get_value("quest_manna_oaks") == 4 then
    game:start_dialog("_oakhaven.npcs.ivystump.lamia.2", function()
      game:set_value("possession_manna_oak_letter", nil)
      game:set_value("quest_manna_oaks", 5) --now go to Amalenchier's tomb
    end)

  elseif game:get_value("quest_manna_oaks") == 5 then
    game:start_dialog("_oakhaven.npcs.ivystump.lamia.3")

  elseif game:get_value("quest_manna_oaks") >= 9 and not game:get_value("ivystump_received_apples_from_lamia") then
    game:start_dialog("_oakhaven.npcs.ivystump.lamia.5", function()
      map:get_hero():start_treasure("apples", 4)
      game:set_value("ivystump_received_apples_from_lamia", true)
    end)

  else
    game:start_dialog("_oakhaven.npcs.ivystump.lamia.6")

  end
end
