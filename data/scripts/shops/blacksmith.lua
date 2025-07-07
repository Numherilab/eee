local shop = {}

function shop:open_shop(game)
  game:start_dialog("_blacksmith." .. math.random(3), function(answer)
      --sword
      if answer == 2 then
        --if your sword is already too powerful
        if game:get_value("sword_damage") >= 10 then
          game:start_dialog("_blacksmith.maxed_out")
        --have required items
        elseif game:has_ability("sword") == true and game:get_item("coral_ore"):get_amount() >= 1 and game:get_money() >= 50 then
          game:set_value("sword_damage", game:get_value("sword_damage") + 1)
          game:remove_money(50)
          game:get_item("coral_ore"):remove_amount(1)
          game:start_dialog("_goatshead.npcs.palladio.sword_improved")
        else --don't have required items
          game:start_dialog("_game.insufficient_items")
        end

      --bow
      elseif answer == 3 then
        --if your bow is already too powerful
        if game:get_value("bow_damage") >= 15 then
          game:start_dialog("_blacksmith.maxed_out")
        --have required items
        elseif game:has_item("bow") == true and game:get_item("coral_ore"):get_amount() >= 1 and game:get_money() >= 50 then
          game:set_value("bow_damage", game:get_value("bow_damage") + 1)
          game:remove_money(50)
          game:get_item("coral_ore"):remove_amount(1)
          game:start_dialog("_goatshead.npcs.palladio.bow_improved")
        else --don't have required items
          game:start_dialog("_game.insufficient_items")
        end

      end -- which answer end

    end) --dialog end
end



return shop
