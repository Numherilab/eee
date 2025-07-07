local map = ...
local game = map:get_game()
local black_screen = sol.surface.create()

map:register_event("on_started", function()
  if (game:get_value("quest_bomb_shop") or 0) >= 3 then
    intern:set_enabled()
  end
end)

function bomb_maker:on_interaction()
  --first, finish bomb shop quest:
  if game:get_value("quest_bomb_shop") == nil or game:get_value("quest_bomb_shop") < 4 then
    local quest_value = game:get_value("quest_bomb_shop")

    --start quest
    if quest_value == nil or quest_value == 0 then
      game:start_dialog("_oakhaven.npcs.bomb_shop.owner.1", function()
        game:set_value("quest_bomb_shop", 1)
      end)

    --started quest
    elseif quest_value == 1 or quest_value == 2 then
      game:start_dialog("_oakhaven.npcs.bomb_shop.owner.2")

    --completed quest
    elseif quest_value == 3 then
      game:start_dialog("_oakhaven.npcs.bomb_shop.owner.3", function()
        game:set_value("quest_bomb_shop", 4)
        game:set_value("available_in_shop_bombs", true) --now you can buy bombs everywhere
        for i = 1, 14 do
          sol.timer.start(map, 200 * i, function()
            sol.audio.play_sound("thunk1")
            map:create_pickable{
              x = 172 + (7 * i), y = 148 + math.random(-4, 16), layer = 0,
              treasure_name = "bomb", treasure_variant = 3,
            }
          end)
        end
      end)
    end
  --otherwise, you can just buy bombs
  else
    game:start_dialog("_oakhaven.npcs.shops.bomb_maker.1", function(answer)

      if answer == 2 then --make bombs
        if game:get_item("firethorn_berries"):get_amount() >= 2 and game:get_money() >= 15 then
          game:remove_money(15)
          game:get_item("firethorn_berries"):remove_amount(2)
          game:get_hero():start_treasure("bomb", 3)
        else
          game:start_dialog("_game.insufficient_items")
        end

      elseif answer == 3 then
        if game:get_value("bomb_damage") < 28 then --max bomb damage
          map:upgrade_bombs()
        else --can't upgrade bombs any further
          game:start_dialog"_oakhaven.npcs.shops.bomb_maker.upgrade_no_more"
        end
      end
    end)
  end
end

function map:upgrade_bombs()
  local ore_amount = game:get_item("coral_ore"):get_amount()
  game:start_dialog("_oakhaven.npcs.shops.bomb_maker.upgrade", function(answer)
    if answer == 1 then
      if game:get_money() >= 200 and ore_amount >= 1 then
          game:set_value("bomb_damage", game:get_value"bomb_damage" + 4 )
          game:remove_money(200)
          game:get_item("coral_ore"):remove_amount(1)
          game:start_dialog("_oakhaven.npcs.shops.bomb_maker.upgrade_done")
      else --don't have ore and money
        game:start_dialog("_game.insufficient_items")
      end
    end
  end)
end




---Intern-----------------
function intern:on_interaction()
  --then, do bomb arrow quest if you have it:
  if game:get_value("quest_bomb_arrows") and game:get_value("quest_bomb_arrows") == 0 then
    game:start_dialog("_oakhaven.npcs.bomb_shop.intern.quest1", function()
      --if you already found the tungsten:
      if game:has_item("tungsten_ore") then
        game:start_dialog("_oakhaven.npcs.bomb_shop.intern.quest_already_tungsten", function()
          game:set_value("quest_bomb_arrows", 2)
        end)
      else
        game:set_value("quest_bomb_arrows", 1)
      end
      game:set_value("possession_bomb_arrow_ticket", nil)
    end)
  --get tungsten
  elseif game:get_value("quest_bomb_arrows") and game:get_value("quest_bomb_arrows") == 1 then
    game:start_dialog"_oakhaven.npcs.bomb_shop.intern.quest2"
  --meet Rusty
  elseif game:get_value("quest_bomb_arrows") and game:get_value("quest_bomb_arrows") == 2 then
    game:start_dialog"_oakhaven.npcs.bomb_shop.intern.quest3"
  --intern makes bomb arrows
  elseif game:get_value("quest_bomb_arrows") and game:get_value("quest_bomb_arrows") == 4 then
    game:start_dialog("_oakhaven.npcs.bomb_shop.intern.quest4", function()
      hero:freeze()
      black_screen:fade_in()
      black_screen:fill_color{0,0,0}
      sol.timer.start(map, 500, function() sol.audio.play_sound"sword_tapping" end)
      sol.timer.start(map, 1200, function() sol.audio.play_sound"sword_tapping" end)
      sol.timer.start(map, 1800, function() sol.audio.play_sound"sword_tapping" end)
      sol.timer.start(map, 2000, function() sol.audio.play_sound"explosion_ice" end)
      sol.timer.start(map, 3000, function()
        black_screen:fade_out()
        sol.timer.start(map, 800, function()
          hero:unfreeze()
          game:set_value("quest_bomb_arrows", 5)
          hero:start_treasure("bow_bombs")
        end)
      end)
    end)
  --no quest
  else
    game:start_dialog"_oakhaven.npcs.bomb_shop.intern.shop_dialog"
  end
end

function map:on_draw(dst)
  black_screen:draw(dst)
end
