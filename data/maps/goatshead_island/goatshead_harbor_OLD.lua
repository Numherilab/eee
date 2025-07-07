local map = ...
require("scripts/multi_events")
local game = map:get_game()
local hero = game:get_hero()
local step_up = sol.movement.create("path")
       step_up:set_path{2,2,2,}
       step_up:set_speed(20)
       step_up:set_ignore_obstacles(true)

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  to_limestone:set_enabled(false)
  yarrowmouth_teletransport:set_enabled(false)
  oakhaven_teletransport:set_enabled(false)
  if game:get_value("goatshead_tunnels_accepted") ~= true then adventurer_3:set_enabled(false) end
  if game:get_value("squid_fled") == true then squid_house_door:set_enabled(false) end
  if game:get_value("phantom_squid_quest_completed") == true then merchant_hopeful:set_enabled(false) end

--setup pre/post Phantom Squid quest fishermen
  if game:get_value("phantom_squid_quest_completed") ~= true then
    --set fishers for after quest disabled
    for postfishers in map:get_entities("postaster_fisher") do
      postfishers:set_enabled(false)
    end
  else
    --set tiles for after quest enabled
    for twofish in map:get_entities("2fish") do
      twofish:set_enabled(true)
    end
    --set fishers from before quest disabled
    for prefishers in map:get_entities("preaster_fisher") do
      prefishers:set_enabled(false)
    end
  end

-- set footprints disabled
  if game:get_value("goatshead_harbor_footprints_visible") == true then
    for prints in map:get_entities("footprint") do
      prints:set_enabled(true)
    end
  else
    for prints in map:get_entities("footprint") do
      prints:set_enabled(false)
    end
  end
  


--movements
  local apples_walk = sol.movement.create("path")
  apples_walk:set_path{4,6,6,6,6,6,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,6,6,6,6,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,2,2,2,2,2,0}
  apples_walk:set_speed(20)
  apples_walk:set_loop(true)
  apples_walk:set_ignore_obstacles(true)
  apples_walk:start(apples_and_oranges_girl)

  local random_walk2 = sol.movement.create("random_path")
  random_walk2:set_speed(10)
  random_walk2:set_ignore_obstacles(false)
  random_walk2:start(market_wanderer)

  local random_walk = sol.movement.create("random_path")
  random_walk:set_speed(10)
  random_walk:set_ignore_obstacles(false)
  random_walk:start(goat_1)



--figure8
  local f8_1_walk = sol.movement.create("path")
  f8_1_walk:set_path{6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,2,2,2,2,2,4,4,4,4,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,2,2,2,2,2,2,2,2,2,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4}
  f8_1_walk:set_speed(25)
  f8_1_walk:set_loop(true)
  f8_1_walk:set_ignore_obstacles(true)
  f8_1_walk:start(figure_8_1)

  local f8_2_walk = sol.movement.create("path")
  f8_2_walk:set_path{6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,2,2,2,2,2,2,2,2,2,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,2,2,2,2,2,4,4,4,4,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,}
  f8_2_walk:set_speed(35)
  f8_2_walk:set_loop(true)
  f8_2_walk:set_ignore_obstacles(true)
  f8_2_walk:start(figure_8_2)

  --dock workers
  local horiz_walk = sol.movement.create("path")
  horiz_walk:set_path{0,0,0,0,0,0,0,0,0,0,0,0,4,4,4,4,4,4,4,4,4,4,4,4}
  horiz_walk:set_speed(20)
  horiz_walk:set_loop()
  horiz_walk:set_ignore_obstacles()
  horiz_walk:start(dockworker_1)

  local horiz_walk2 = sol.movement.create("path")
  horiz_walk2:set_path{0,0,0,0,0,0,0,0,0,0,0,0,4,4,4,4,4,4,4,4,4,4,4,4}
  horiz_walk2:set_speed(20)
  horiz_walk2:set_loop()
  horiz_walk2:set_ignore_obstacles()
  horiz_walk2:start(dockworker_3)

end)


-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
map:register_event("on_opening_transition_finished", function()

  if game:get_value("goatshead_opening") ~= true then
    game:start_dialog("_goatshead.npcs.juglan.1", function()
      game:set_value("quest_meet_juglan_at_pier",1)  --quest log
      game:set_value("quest_log_a", "a3")
      game:set_value("goatshead_opening", true)
    end)

  end
end)



--NPC INTERACTIONS

function juglan:on_interaction()
game:start_dialog("_goatshead.npcs.juglan.ride_back", function(answer)
      if answer == 2 then
          to_limestone:set_enabled(true)
      end
      end)
end


function upset_fisher:on_interaction()
  if game:get_value("two_eye_rock_shroom_defeated") == nil then
    game:start_dialog("_goatshead.npcs.upset_fisher.1")
    game:set_value("quest_test13", 0)
  else
    if game:get_value("manly_carrot_man_paid") ~= true then
      game:start_dialog("_goatshead.npcs.upset_fisher.2", function() game:add_money(80) end)
      game:set_value("manly_carrot_man_paid", true)
      game:set_value("quest_test13", 2)
    else
      game:start_dialog("_goatshead.npcs.upset_fisher.3")
    end
  end
end

function orange_salesman:on_interaction()

end



function postaster_fisher:on_interaction()
  game:start_dialog("_goatshead.npcs.fish_mongers.5", function() game:add_life(4) end)
end


--town guards
function guard_1:on_interaction()
  if game:get_value("barbell_brutes_defeated") ~= true then
    game:start_dialog("_goatshead.npcs.guards.1")
  else
    game:start_dialog("_goatshead.npcs.guards.post_defeat.2")
  end
end

function guard_2:on_interaction()
  if game:get_value("barbell_brutes_defeated") ~= true then
    game:start_dialog("_goatshead.npcs.guards.2")
  else
    game:start_dialog("_goatshead.npcs.guards.post_defeat.3")
  end
end

function guard_3:on_interaction()
  if game:get_value("barbell_brutes_defeated") ~= true then
    game:start_dialog("_goatshead.npcs.guards.3")
  else
    game:start_dialog("_goatshead.npcs.guards.post_defeat.1")
  end
end

function guard_4:on_interaction()
  if game:get_value("barbell_brutes_defeated") ~= true then
    game:start_dialog("_goatshead.npcs.guards.4")
  else
    game:start_dialog("_goatshead.npcs.guards.post_defeat.1")
  end
end

function guard_5:on_interaction()
  if game:get_value("barbell_brutes_defeated") ~= true then
    game:start_dialog("_goatshead.npcs.guards.8")
  else
    game:start_dialog("_goatshead.npcs.guards.post_defeat.1")
  end
end

--Ferries
function yarrowmouth_ferry:on_interaction()
  game:start_dialog("_ferries.yarrowmouth", function(answer)
    if answer == 3 then
      if game:get_money() >9 then
        game:remove_money(10)
        hero:teleport("Yarrowmouth/yarrowmouth_village", "ferry_landing")
      else
        game:start_dialog("_game.insufficient_funds")
      end
    end
  end)
end

function oakhaven_ferry:on_interaction()
  game:start_dialog("_ferries.oakhaven", function(answer)
    if answer == 3 then
      if game:get_money() >9 then
        game:remove_money(10)
        hero:teleport("oakhaven/port", "from_ferry")
      else
        game:start_dialog("_game.insufficient_funds")
      end
    end
  end)
end