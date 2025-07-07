-- Boutique générale - Modèle de base
local shop = {}

-- Configuration de la boutique
local shop_items = {
  {
    item_id = "berries",
    variant = 3,
    price = 5,
    availability_variable = "available_in_shop_berries",
    dialog_id = "_shop.berries"
  },
  {
    item_id = "apples", 
    variant = 2,
    price = 12,
    availability_variable = "available_in_shop_apples",
    dialog_id = "_shop.apples"
  },
  {
    item_id = "bread",
    variant = 2, 
    price = 45,
    availability_variable = "available_in_shop_bread",
    dialog_id = "_shop.bread"
  },
  {
    item_id = "arrow",
    variant = 3,
    price = 10,
    availability_variable = "available_in_shop_arrows", 
    dialog_id = "_shop.arrows"
  },
  {
    item_id = "bomb",
    variant = 3,
    price = 30,
    availability_variable = "available_in_shop_bombs",
    dialog_id = "_shop.bombs"
  }
}

-- Fonction pour ouvrir la boutique
function shop:open_shop(game)
  -- Message d'accueil du marchand
  game:start_dialog("_shop.welcome", function(answer)
    if answer == 2 then
      -- Le joueur veut acheter quelque chose
      self:show_shop_menu(game)
    elseif answer == 3 then
      -- Le joueur veut vendre quelque chose (optionnel)
      self:show_sell_menu(game)
    end
    -- Sinon, le joueur quitte (answer == 1)
  end)
end

-- Fonction pour afficher le menu d'achat
function shop:show_shop_menu(game)
  -- Utiliser le menu de boutique existant
  local shop_menu = require("scripts/shops/shop_menu")
  shop_menu:start(game)
end

-- Fonction pour afficher le menu de vente (optionnel)
function shop:show_sell_menu(game)
  local sell_menu = require("scripts/shops/sell_menu")
  sell_menu:start(game)
end

-- Fonction pour acheter un objet spécifique
function shop:buy_item(game, item_data)
  local item = game:get_item(item_data.item_id)
  local price = item_data.price
  
  -- Vérifier si l'objet est disponible
  if item_data.availability_variable and not game:get_value(item_data.availability_variable) then
    game:start_dialog("_shop.item_not_available")
    return
  end
  
  -- Vérifier si le joueur a assez d'argent
  if game:get_money() < price then
    game:start_dialog("_game.insufficient_funds")
    return
  end
  
  -- Vérifier si le joueur peut porter plus de cet objet
  if item:has_amount() and item:get_amount() >= item:get_max_amount() then
    game:start_dialog("_shop.inventory_full")
    return
  end
  
  -- Confirmer l'achat
  game:start_dialog("_shop.confirm_purchase", item_data.item_id, price, function(answer)
    if answer == 2 then -- Oui
      -- Effectuer la transaction
      game:remove_money(price)
      
      if item:has_amount() then
        item:add_amount(item_data.variant or 1)
      else
        item:set_variant(item_data.variant or 1)
      end
      
      -- Jouer le son d'achat
      game:start_dialog("_shop.purchase_success", item_data.item_id)
      
      -- Proposer un autre achat
      game:start_timer(1000, function()
        self:open_shop(game)
      end)
    else
      -- Retour au menu principal
      self:open_shop(game)
    end
  end)
end

-- Fonction pour vendre un objet
function shop:sell_item(game, item_id, quantity, price_per_unit)
  local item = game:get_item(item_id)
  local total_price = price_per_unit * quantity
  
  -- Vérifier que le joueur a assez d'objets
  if not item:has_amount() or item:get_amount() < quantity then
    game:start_dialog("_shop.insufficient_items")
    return
  end
  
  -- Confirmer la vente
  game:start_dialog("_shop.confirm_sale", item_id, quantity, total_price, function(answer)
    if answer == 2 then -- Oui
      -- Effectuer la transaction
      item:remove_amount(quantity)
      game:add_money(total_price)
      
      -- Jouer le son de vente
      game:start_dialog("_shop.sale_success", item_id, total_price)
      
      -- Proposer une autre vente
      game:start_timer(1000, function()
        self:show_sell_menu(game)
      end)
    else
      -- Retour au menu de vente
      self:show_sell_menu(game)
    end
  end)
end

-- Fonction utilitaire pour vérifier si un objet est disponible à l'achat
function shop:is_item_available(game, item_data)
  if not item_data.availability_variable then
    return true
  end
  return game:get_value(item_data.availability_variable) == true
end

-- Fonction pour obtenir le prix d'un objet
function shop:get_item_price(item_data)
  return item_data.price
end

-- Fonction pour mettre à jour la disponibilité des objets
function shop:update_item_availability(game, item_id, available)
  for _, item_data in ipairs(shop_items) do
    if item_data.item_id == item_id and item_data.availability_variable then
      game:set_value(item_data.availability_variable, available)
      break
    end
  end
end

return shop
