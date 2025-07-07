local map = ...
local game = map:get_game()

local shop_items = {
    {item = "berries", price = 5, variant = 3,
      availability_variable = "available_in_shop_berries"},
    {item = "apples", price = 12, variant = 2,
      availability_variable = "available_in_shop_apples"},
    {item = "bread", price = 45, variant = 2,
      availability_variable = "available_in_shop_bread"},
    {item = "elixer", price = 100, variant = 1,
      availability_variable = "available_in_shop_elixer"},
    {item = "potion_magic_restoration", price = 50, variant = 1,
      availability_variable = "available_in_shop_magic_restoring_potion"},
    {item = "unattainable_collectable",price=0,variant=1,availability_variable="nil"},
    {item = "arrow", price = 10, variant = 3,
      availability_variable = "available_in_shop_arrows"},
    {item = "bomb", price = 30, variant = 3,
      availability_variable = "fykonos_bombs_available"},
    {item = "berries", price = 20, variant = 4,
      availability_variable = "available_in_shop_berries"},
    {item = "apples", price = 40, variant = 4,
      availability_variable = "available_in_shop_apples"},
    {item = "bread", price = 90, variant = 3,
      availability_variable = "available_in_shop_bread"},
    {item = "potion_stoneskin", price = 80, variant = 1,
      availability_variable = "available_in_shop_stoneskin_potion"},
    {item = "potion_burlyblade", price = 80, variant = 1,
      availability_variable = "available_in_shop_burlyblade_potion"},
    {item = "unattainable_collectable",price=0,variant=1,availability_variable="nil"},
    {item = "arrow", price = 40, variant = 5,
      availability_variable = "available_in_shop_arrows"},
    {item = "bomb", price = 60, variant = 4,
      availability_variable = "fykonos_bombs_available"},
}


map:register_event("on_started", function()
  if game:get_value"fykonos_bombs_available" then bombino:set_enabled(true) end
end)


function shopkeeper:on_interaction()
  local dialog = "_fykonos.npcs.village.shopkeeper." .. math.random(1, 3)
  game:start_dialog(dialog, function()
    local shop_menu = require("scripts/shops/shop_menu")
    shop_menu:set_items_for_sale(shop_items)
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

