local map = ...
local game = map:get_game()
local hero = game:get_hero()
local item_lander_x = 200
local item_lander_y = 120



function shopkeeper:on_interaction()
  game:start_dialog("_oakhaven.npcs.shops.general_store.1", function()
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
