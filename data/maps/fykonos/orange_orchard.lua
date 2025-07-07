
local map = ...
local game = map:get_game()

function andei:on_interaction()
  if game:get_value"tic_tac_prize_money_status" == "keep" and not game:get_value"fykonos_orange_money_resolved" then
    --let Aubrey keep the prize money from Oakhaven tic tac toe championship
    game:start_dialog("_fykonos.npcs.orchard.andei.2", function()
      game:set_value("fykonos_orange_money_resolved", true)
      game:add_money(200)
    end)
  else
    game:start_dialog("_fykonos.npcs.orchard.andei.1")
  end
end
