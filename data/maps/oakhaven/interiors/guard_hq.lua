local map = ...
local game = map:get_game()

function guard_captain:on_interaction()
  if game:get_value("quest_mayors_dog") == nil then
    game:start_dialog("_oakhaven.npcs.guards.hq.captain.1_ask", function(answer)
      if answer == 2 then
        game:start_dialog("_oakhaven.npcs.guards.hq.captain.2_quest", function()
          game:set_value("quest_mayors_dog", 0)
        end)
      end
    end)

  elseif game:get_value("quest_mayors_dog") < 11 then
    game:start_dialog("_oakhaven.npcs.guards.hq.captain.3")

  elseif game:get_value("quest_mayors_dog") == 11 then
    game:start_dialog("_oakhaven.npcs.guards.hq.captain.4", function()
      game:add_money(200)
      game:set_value("quest_mayors_dog", 12)
    end)

  elseif game:get_value("quest_mayors_dog") == 12 then
    game:start_dialog("_oakhaven.npcs.guards.hq.captain.5")

  end
end
