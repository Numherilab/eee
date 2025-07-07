local map = ...
local game = map:get_game()

function shopkeeper:on_interaction()
  game:start_dialog("_oakhaven.npcs.market.8", function(answer)
    if answer == 1 then
      if game:get_money() >= 40 then
        hero:start_treasure("bread", 2)
        game:remove_money(40)
      else game:start_dialog"_game.insufficient_funds"
      end
    end
  end)
end
