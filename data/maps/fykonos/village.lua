local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  if game:get_item("bombs_counter_2"):has_amount(1) and lost_bombs then lost_bombs:set_enabled(true) end
  if game:has_item"bow" and lost_arrows then lost_arrows:set_enabled(true) end

  --Bell
  bell:set_layer_independent_collisions(true)
  bell:add_collision_test("sprite", function(bell, entity, bellsprite, entitysprite)
    if not bell.ringing
    and entitysprite:get_animation_set() == "hero/sword1" or entitysprite:get_animation_set() == "hero/spear" then
      sol.audio.play_sound"bell_town"
      bell:get_sprite():set_animation"ringing"
      bell.ringing = true
      sol.timer.start(map, 5800, function()
        bell.ringing = false
        bell:get_sprite():set_animation"stopped"
      end)
    end
  end)

end)

function greeter:on_interaction()
  if not game:get_value"fykonos_talked_with_greeter" then
    game:start_dialog"_fykonos.npcs.village.greeter.1"
    game:set_value("fykonos_talked_with_greeter", true)
  else
    game:start_dialog"_fykonos.npcs.village.greeter.2"
  end
end



function ferry_counter:on_interaction()
  if not game:get_value"fykonos_defeated_ophira" then
    --ferry closed
    game:start_dialog"_fykonos.npcs.village.ferry.closed"
  else
    --ferry open
    if game:get_value"quest_fykonos" <= 3 then game:set_value("quest_fykonos", 3) end
    game:start_dialog("_fykonos.npcs.village.ferry.open", function(answer)
      if answer == 3 then
        --ride ferry
        hero:teleport("oakhaven/port", "from_fykonos")
      end
    end)
  end
end


function cafe_counter:on_interaction()
  game:start_dialog("_fykonos.npcs.village.cafe.1", function(answer)
    if answer == 2 then --buy
      if game:get_money() >= 10 then
        game:remove_money(10)
        game:add_life(6)
        game:get_item("potion_fleetseed"):drink()
        
      else
        game:start_dialog"_game.insufficient_funds"
      end
    end
  end)
end


