local map = ...
local game = map:get_game()



function market_shop:on_interaction()
  game:start_dialog("_ballast_harbor.npcs.market_people.shop", function()
    local shop_menu = require("scripts/shops/shop_menu")
    shop_menu:initialize(game)
    sol.menu.start(map, shop_menu)
  end)
end

function buyer_guy:on_interaction()
  game:start_dialog("_generic_dialogs.buyer_guy.1", function()
    local sell_menu = require("scripts/shops/sell_menu")
    sell_menu:initialize(game)
    sol.menu.start(map, sell_menu)
  end)
end