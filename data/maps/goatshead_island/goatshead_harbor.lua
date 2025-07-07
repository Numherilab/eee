-- Lua script of map goatshead_island/goatshead_harbor.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = game:get_hero()

map:register_event("on_started", function()
  if game:get_value("goatshead_opening") == true then juglan:set_enabled(false) juglan_boat:remove() end
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

  if game.footrace_timer then
    sol.achievements.unlock("ach_footrace")
  end  


--movements
  local apples_walk = sol.movement.create("path")
  apples_walk:set_path{4,6,6,6,6,6,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,6,6,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,2,2,2,2,2,0}
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
      hero:start_treasure("fast_travel_chart_limestone_island")
      game:set_value("quest_meet_juglan_at_pier",1)  --quest log
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
  if not game:get_value("quest_test13") then
    --normal sequence
    if not game:get_value"goatshead_island_two_eye_rock_shroom_dead" then
      game:start_dialog("_goatshead.npcs.upset_fisher.1", function()
        game:set_value("quest_test13", 0)
      end)
    else -- you defeated the monsters before talking to him
      game:start_dialog("_goatshead.npcs.upset_fisher.2", function()
        game:add_money(80)
        game:set_value("quest_test13", 2)
      end)
    end

  elseif game:get_value("quest_test13") == 0 then
    game:start_dialog("_goatshead.npcs.upset_fisher.1")
  elseif game:get_value("quest_test13") == 1 then
      game:start_dialog("_goatshead.npcs.upset_fisher.2", function() game:add_money(80) end)
      game:set_value("quest_test13", 2)
  elseif game:get_value("quest_test13") == 2 then
      game:start_dialog("_goatshead.npcs.upset_fisher.3")
  end
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
