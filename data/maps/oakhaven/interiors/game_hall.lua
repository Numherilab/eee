local map = ...
local game = map:get_game()
local hero = map:get_hero()

map:register_event("on_started", function()
  guard:set_enabled(false)
  ana_2:set_enabled(false)
  if game:get_value("quest_tic_tac_toe") == 0 then ana_2:set_enabled(true) end
  if game:get_value("oakhaven_tic_tac_treasure_stolen") == nil then orange_peel:set_enabled(false) end
  if game:get_value("oakhaven_tic_tac_treasure_stolen")  == true then ana_1:set_enabled(false) end
  if game:get_value("orange_ana_on_the_run") == true then
    competitor_1:set_enabled(false)
    competitor_2:set_enabled(false)
    competitor_3:set_enabled(false)
    competitor_4:set_enabled(false)
  end

end)

function chest:on_interaction()
  game:start_dialog("_oakhaven.npcs.game_hall.chest1")
end



--REFEREE
function referee:on_interaction()
  --first encounter
  if game:get_value("tic_tac_referee_counter") == nil then
    game:start_dialog("_oakhaven.npcs.game_hall.officiant.1", function(answer)
    if answer == 2 then
      game:start_dialog("_oakhaven.npcs.game_hall.officiant.2", function()
        hero:teleport("oakhaven/interiors/game_hall", "tic_tac_seat")
        start_tournament()
      end) --end of dialog callback
    end--end of answering yes
    end) --end of dialog 1 callback

  --while the guards are searching
  elseif game:get_value("tic_tac_referee_counter") == 1 then
    game:start_dialog("_oakhaven.npcs.game_hall.officiant.4")

  --after Ana escapes
  elseif game:get_value("tic_tac_referee_counter") == 2 then
    game:start_dialog("_oakhaven.npcs.game_hall.officiant.5", function()
      if game:get_value("oakhaven_checkout_out_pile_of_orange_peels_in_game_hall") == true then
        game:set_value("quest_tic_tac_toe", 3) --quest log
      else
        game:set_value("quest_tic_tac_toe", 2) --quest log
      end
      game:set_value("tic_tac_referee_counter", 55) --I messed up the numbering system, oops
    end)

  --still looking for Aubrey (I changed her name halfway through)
  elseif game:get_value("tic_tac_referee_counter") == 55 then
    game:start_dialog("_oakhaven.npcs.game_hall.officiant.55")

  --if you got the money back from Aubrey
  elseif game:get_value("tic_tac_referee_counter") == 3 then
    game:start_dialog("_oakhaven.npcs.game_hall.officiant.6", function()
      game:remove_money(100)
      game:set_value("possession_prize_money", nil)
      game:set_value("tic_tac_referee_counter", 4)
      game:set_value("quest_tic_tac_toe", 8) --quest log
    end)

  --if you gave the money back to the referee
  elseif game:get_value("tic_tac_referee_counter") == 4 then
    game:start_dialog("_oakhaven.npcs.game_hall.officiant.7")

  end
end

function start_tournament()
  sol.timer.start(400, function()
    ana_1:set_enabled(false)
    ana_2:set_enabled(true)
    orange_peel:set_enabled(true)
  end)

    --open the chest after a second
    sol.timer.start(2500, function()
      chest:get_sprite():set_animation("open")
      sol.audio.play_sound("chest_open")
    end)

  game:start_dialog("_oakhaven.npcs.game_hall.officiant.3", function()
    guard:set_enabled(true)
    local m = sol.movement.create("path")
    m:set_path{2, 2, 2, 2}
    m:set_ignore_obstacles()
    m:start(guard)
    game:set_value("oakhaven_tic_tac_treasure_stolen", true)
    game:set_value("tic_tac_referee_counter", 1)
    game:set_value("quest_tic_tac_toe", 0) --quest log, start quest
  end)--end of dialog function
end


function ana_2:on_interaction()
  game:start_dialog("_oakhaven.npcs.ana_orange.2", function()
  hero:freeze()
  map:get_camera():start_tracking(ana_2)
  local m = sol.movement.create("path")
  m:set_path{4,4,4,4,4,4,6,6,6,6,6,6,6,6,0,0,6,6,6,6,6,6,6,6,4,4,4,4,4,4,6,6}
  m:set_speed(200)
  m:set_ignore_obstacles()
  m:start(ana_2, function()

    sol.audio.play_sound("breaking_glass")
    broken_window:set_enabled(true)
    ana_2:set_enabled(false)
    game:set_value("tic_tac_referee_counter", 2)
    game:set_value("orange_ana_on_the_run", true)
    sol.timer.start(1000, function()
      map:get_camera():start_tracking(hero)
      hero:unfreeze()
      game:set_value("quest_tic_tac_toe", 1)
    end)


  end)

  end)
end


function guard:on_interaction()
  --ana is run away
  if game:get_value("orange_ana_on_the_run") == true then
    game:start_dialog("_oakhaven.npcs.game_hall.guard2", function()
    hero:freeze()
    local m = sol.movement.create("path")
    m:set_path{6,6,6,6}
    m:set_ignore_obstacles()
    m:start(guard, function()
      guard:set_enabled(false)
      hero:unfreeze()
    end)

    end)
  --ana hasn't gone yet
  else
    game:start_dialog("_oakhaven.npcs.game_hall.guard")
  end


end


function competitor_1:on_interaction()
  if game:get_value("oakhaven_tic_tac_treasure_stolen") == nil then
    game:start_dialog("_oakhaven.npcs.game_hall.competitors.1")
  else
    game:start_dialog("_oakhaven.npcs.game_hall.competitors.b1")
  end
end

function competitor_2:on_interaction()
  if game:get_value("oakhaven_tic_tac_treasure_stolen") == nil then
    game:start_dialog("_oakhaven.npcs.game_hall.competitors.2")
  else
    game:start_dialog("_oakhaven.npcs.game_hall.competitors.b2")
  end
end

function competitor_3:on_interaction()
  if game:get_value("oakhaven_tic_tac_treasure_stolen") == nil then
    game:start_dialog("_oakhaven.npcs.game_hall.competitors.3")
  else
    game:start_dialog("_oakhaven.npcs.game_hall.competitors.b3")
  end
end

function competitor_4:on_interaction()
  if game:get_value("oakhaven_tic_tac_treasure_stolen") == nil then
    game:start_dialog("_oakhaven.npcs.game_hall.competitors.4")
  else
    game:start_dialog("_oakhaven.npcs.game_hall.competitors.b4")
  end
end


--THAT PILE OF ORANGE PEELS!
function orange_peel:on_interaction()
  if (game:get_value("oakhaven_fruit_importer_counter") or 0) < 1 then
    game:set_value("oakhaven_fruit_importer_counter", 1)
  end
  game:set_value("oakhaven_checkout_out_pile_of_orange_peels_in_game_hall", true)
  game:start_dialog("_oakhaven.npcs.game_hall.orange_peel")
  if game:get_value("quest_tic_tac_toe") == 2 then
    game:set_value("quest_tic_tac_toe", 3) --quest log
  end
end
