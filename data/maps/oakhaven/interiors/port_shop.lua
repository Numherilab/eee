local map = ...
local game = map:get_game()

function shopkeeper:on_interaction()
  game:start_dialog("_oakhaven.npcs.shops.general_store.2", function()
    local shop_menu = require("scripts/shops/shop_menu")
    shop_menu:initialize(game)
    sol.menu.start(map, shop_menu)
  end)
end