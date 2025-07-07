local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  map:cloud_overlay()
  --handle blackbeard
  blackbeard:set_enabled(false)
  --handle Morus
--[[  morus:set_enabled(false)
  if game:get_value("morus_at_port") == true then
    morus_boat_steam:set_enabled(true)
    morus:set_enabled(true)
  end --]]
  --put Hazel Ally on the map
  if game:get_value("hazel_is_currently_following_you") and not game:get_value("spoken_to_hazel_south_gate") then
    hazel_dummy:set_enabled(true)
  elseif game:get_value("hazel_is_currently_following_you") and game:get_value("spoken_to_hazel_south_gate") then
    require("scripts/action/hazel_ally"):summon(hero)
  end
  --That guy with the boxes that blocks the way into town if you haven't done the plot enough
  if game:get_value("quest_hazel") then
    for block in map:get_entities("block_guy") do block:set_enabled(false) end
  end
  --if you're coming out of the arena, remove the pots blocking the door
  for pot in map:get_entities("blockpot") do
    if pot:get_distance(hero) < 100 then pot:remove() end
  end
  --barbell brutes vice captain
  if game:get_value("barbell_brutes_defeated") == true then
    vice_captain:set_enabled(true) wine:set_enabled(true)
  end

  --NPC movements:
  local nailm = sol.movement.create("straight")
  local nailmangle = 0
  nailm:set_angle(nailmangle)
  nailm:set_speed(20)
  nailm:start(nailman)
  function nailm:on_obstacle_reached()
    nailmangle = nailmangle + math.pi
    nailm:set_angle(nailmangle)
    nailm:start(nailman)
  end

  --Setup for Quests:
  if game:get_value("find_burglars") == true then burglar_lookout:set_enabled(false) end
  if game:get_value("quest_mayors_dog") and game:get_value("quest_mayors_dog") >=8 then
    see_litton_sensor:set_enabled(false)
  end
  if game:get_value("quest_mayors_dog") == 7 then running_litton:set_enabled(true) end
  if game:get_value("quest_bomb_arrows") and game:get_value("quest_bomb_arrows") >= 4 then
    gallery_door:set_enabled(false) 
    gallery_door_npc:set_enabled(false)
  end

  --Fykonos Quest
  if (game:has_item"bow" and game:has_item"spear")
  or (game:get_value"quest_fykonos" and game:get_value"quest_fykonos" >= 2) then
    max:set_enabled(true)
    fykonos_boat:set_enabled(true)
  end

end)



--Blackbeard
function blackbeard_sensor:on_activated()
  if game:get_value("find_burglars") == true and game:get_value("oak_port_blackbeard_cutscene") == nil then
    game:set_value("oak_port_blackbeard_cutscene", true)
    map:get_hero():freeze()
    blackbeard:set_enabled(true)
    local p1 = sol.movement.create("path")
    p1:set_speed(70)
    p1:set_path{6,6,6,6,6,6,6,6,6,6,6,6,4,4,6,6}
    p1:set_ignore_obstacles(true)
    p1:start(blackbeard)

    function p1:on_finished()
      game:start_dialog("_oakhaven.npcs.port.blackbeard.1", function()
        p1:set_path{6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,6,6,6,6,6,6,6,6,6,6}
        p1:start(blackbeard)
        function p1:on_finished()
          blackbeard:set_enabled(false)
          map:get_hero():unfreeze()
        end--end of p1:on_finished
      end)--end of after dialog function
    end--end of p1:on_finished()
  end--end of conditional branch
end


--Morus
--[[
function morus:on_interaction()
  if game:has_item("oceansheart_chart") == true then
    game:start_dialog("_oakhaven.npcs.morus.ferry_2", function(answer)
      if answer == 1 then
        game:start_dialog("_oakhaven.npcs.morus.ferry_already")
      elseif answer == 2 then
        hero:teleport("snapmast_reef/snapmast_landing", "ferry_landing")
      elseif answer == 3 then
        hero:teleport("isle_of_storms/isle_of_storms_landing", "ferry_landing")
      end
    end)
  else
    game:start_dialog("_oakhaven.npcs.morus.ferry_1", function(answer)
      if answer == 2 then
        hero:teleport("snapmast_reef/snapmast_landing", "ferry_landing")
      end
    end)
  end
end
--]]

--Hazel (go to Gull Rock)
function meet_hazel_sensor:on_activated()
  if game:get_value("hazel_is_currently_following_you") and not game:get_value("spoken_to_hazel_south_gate") then
    game:start_dialog("_oakhaven.npcs.hazel.thicket.1")
    game:set_value("spoken_to_hazel_south_gate", true)
    local m = sol.movement.create("target")
    m:set_ignore_obstacles()
    m:start(hazel_dummy, function()
      hazel_dummy:set_enabled(false)
      local x,y,z = hazel_dummy:get_position()
      map:create_custom_entity{
        x=x, y=y, layer=z, direction=3, width=16, height=16,
        sprite = "npc/hazel",
        model = "ally",
        name = "hazel"
      }
    end)
  end
  meet_hazel_sensor:set_enabled(false)
end

for guard in map:get_entities("guard") do
function guard:on_interaction()
  if game:get_value("quest_mayors_dog") == 8 then
    game:start_dialog("_oakhaven.npcs.guards.port.2", function()
      game:set_value("quest_mayors_dog", 9)
    end)
  else
    game:start_dialog("_oakhaven.npcs.guards.port.1")
  end

end
end


--Litton
function see_litton_sensor:on_activated()
  if game:get_value("quest_mayors_dog") == 7 then
    hero:freeze()
    local m = sol.movement.create("path")
    m:set_path{6,6,6,6,6,6,6,6,6,6,6,6,6,6}
    m:set_speed(100)
    m:start(running_litton, function()
      hero:unfreeze()
      running_litton:set_enabled(false)
      game:set_value("quest_mayors_dog", 8)
    end)
    see_litton_sensor:set_enabled(false)
  end
end

--Guard who tells you about Litton
function guard_1:on_interaction()
  if game:get_value("quest_mayors_dog") == 7 then
    game:start_dialog"_oakhaven.npcs.guards.port.2"
  else
    game:start_dialog"_oakhaven.npcs.guards.port.1"
  end
end

function guard_3:on_interaction()
  if game:get_value("quest_mayors_dog") == 7 then
    game:start_dialog"_oakhaven.npcs.guards.port.4"
  else
    game:start_dialog"_oakhaven.npcs.guards.port.3"
  end
end


--Gallery for Bomb Arrows Quest
function gallery_door_npc:on_interaction()
  if game:get_value("quest_bomb_arrows") and game:get_value("quest_bomb_arrows") == 3 then
    game:start_dialog("_oakhaven.npcs.shipyard.gallery_door2", function()
      gallery_door:set_enabled(false)
      gallery_door_npc:set_enabled(false)
    end)
  else
    game:start_dialog("_oakhaven.npcs.shipyard.gallery_door1")
  end
end

--Buyer Guy
function buyer_guy:on_interaction()
  game:start_dialog("_generic_dialogs.buyer_guy.1", function()
    local sell_menu = require("scripts/shops/sell_menu")
    sell_menu:initialize(game)
    sol.menu.start(map, sell_menu)
  end)
end

--Jose hagfish seller
function jose_hagfish:on_interaction()
  game:start_dialog("_oakhaven.npcs.port.misc.3", function(answer)
    if answer == 1 then
      game:start_dialog("_oakhaven.npcs.port.misc.3-2", function()
        game:remove_life(1)
        sol.audio.play_sound"hero_hurt"
        hero:set_blinking(true, 5)
      end)
    end
  end)
end

--Fykonos Boat
function max:on_interaction()
  if not game:get_value"fykonos_defeated_ophira" then
    game:start_dialog("_fykonos.npcs.max.real_game_dialog", function(answer)
      if answer == 2 then
        game:start_dialog("_fykonos.npcs.max.real_game_dialog_2", function()
          game:set_value("fykonos_not_demo", true)
          hero:teleport("fykonos/intro/ship_below_deck", "arrival_destination")
        end)
      end
    end)
  else
    game:start_dialog("_fykonos.npcs.max.oakhaven_normal_ferry", function(answer)
      if answer == 3 then
        hero:teleport("fykonos/village", "from_oakhaven")
      end
    end)
  end
end

function footrace_sensor:on_activated()
  game.footrace_timer = sol.timer.start(game, 67000, function()
    game.footrace_timer = nil
  end)
end
