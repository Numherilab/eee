local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  if game:get_value("aubrey_defeated") then walking_in_sensor:set_enabled(false) end
end)

function walking_in_sensor:on_activated()
  hero:freeze()
  hero:set_animation"walking"
  local m = sol.movement.create"straight"
  m:set_angle(math.pi / 2)
  m:set_max_distance(24)
  m:start(hero, function()
    hero:set_animation"stopped"
    map:change_crystal_state()
    game:start_dialog("_oakhaven.npcs.ana_orange.get_into_fight", function()
      walking_in_sensor:set_enabled(false)
      aubrey:set_enabled(false)
      aubrey_enemy:set_enabled(true)
      hero:unfreeze()
    end)
  end)
end


function aubrey_enemy:on_dying()
  aubrey:set_position(aubrey_enemy:get_position())
  aubrey:set_enabled(true)
  game:set_value("aubrey_defeated", true)
end

function aubrey_enemy:on_dead()
  game:start_dialog("_oakhaven.npcs.ana_orange.alright", function()
  map:change_crystal_state()
  local m = sol.movement.create"target"
  local x,y,z = aubrey:get_position()
  m:set_target(x, y + 16)
  m:set_speed(70)
  m:set_ignore_obstacles(true)
  hero:freeze()
  hero:set_animation"walking"
  m:start(hero, function()
    hero:set_animation"stopped"
    hero:set_direction(1)
    aubrey:on_interaction()
  end)
  end)
end


function aubrey:on_interaction()
  --confront aubrey!
  if game:get_value("tic_tac_prize_money_status") == nil then
    aubrey_first_conversation()

  --if you took the money from her
  elseif game:get_value("tic_tac_prize_money_status") == "return" then
    game:start_dialog("_oakhaven.npcs.ana_orange.4")

  --if you let her keep the money
  elseif game:get_value("tic_tac_prize_money_status") == "keep" then
    game:start_dialog("_oakhaven.npcs.ana_orange.5")
  end
  hero:unfreeze()
end

function aubrey_first_conversation()
  game:start_dialog("_oakhaven.npcs.ana_orange.3", function(answer)
    game:set_value("possession_oranges_shipment", nil)

    --hand over the money!
    if answer == 2 then
    game:start_dialog("_oakhaven.npcs.ana_orange.take_money", function()
      game:add_money(200)
      game:set_value("possession_prize_money", 1)
      game:set_value("tic_tac_referee_counter", 3)
      game:set_value("quest_tic_tac_toe", 6) --quest log
      game:set_value("tic_tac_prize_money_status", "return")
    end)

    --keep it
    elseif answer == 3 then
    game:start_dialog("_oakhaven.npcs.ana_orange.keep_money", function()
      game.objectives:set_alternate("orange_thief", "quest.side.oakhaven.orange_thief_aubrey")
      game:set_value("quest_tic_tac_toe", 8) --quest log
      game:set_value("tic_tac_prize_money_status", "keep")
    end)

    end
  end)
end
