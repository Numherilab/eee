local map = ...
local game = map:get_game()


map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(2)
  sol.menu.start(map, lighting_effects)

  sol.achievements.unlock("ach_oakport_arena")
end)

---Bomb Arrow Quest:
function rusty:on_interaction()
  if (game:get_value("quest_bomb_arrows") or 0) == 2 then
    game:start_dialog("_oakhaven.npcs.port.rusty.1", function()
      game:set_value("quest_bomb_arrows", 3)
    end)
  else
    game:start_dialog"_oakhaven.npcs.port.rusty"
  end
end

--Arena Fights----------------------------------------------------
local random_potion_table = {"potion_burlyblade","potion_fleetseed","potion_stoneskin","elixer"}
local random_consumable_table = {"ether_bombs_pickable","iron_candle_pickable","homing_eye_pickable","bomb"}

local prizes1 = {
  {"rupee", 2},
  {"rupee", 2},
  {"rupee", 2},
  {"rupee", 2},
  {"rupee", 2},
  {"rupee", 2},
  {"bread", 2},
  {"bread", 2},
  {"monster_bones", 2},
  {"monster_bones", 2},
  {"monster_eye", 1},
}
local prizes2 = {
  {"rupee", 3},
  {"rupee", 3},
  {"rupee", 3},
  {"rupee", 3},
  {"rupee", 2},
  {"rupee", 2},
  {"rupee", 2},
  {"rupee", 2},
  {"rupee", 2},
  {"elixer", 1},
  {random_potion_table[math.random(1,4)], 1},
  {random_consumable_table[math.random(1,4)], 2},
  {random_consumable_table[math.random(1,4)], 2},
  {random_consumable_table[math.random(1,4)], 2},
  {random_consumable_table[math.random(1,4)], 2},
  {"bread", 2},
  {"bread", 2},
}
local prizes3 = {
  {"rupee", 3},
  {"rupee", 3},
  {"rupee", 3},
  {"rupee", 3},
  {"rupee", 3},
  {"rupee", 4},
  {"rupee", 4},
  {"elixer", 1},
  {random_potion_table[math.random(1,4)], 1},
  {random_potion_table[math.random(1,4)], 1},
  {random_consumable_table[math.random(1,4)], 2},
  {random_consumable_table[math.random(1,4)], 2},
  {random_consumable_table[math.random(1,4)], 2},
  {random_consumable_table[math.random(1,4)], 2},
  {random_consumable_table[math.random(1,4)], 2},
  {random_consumable_table[math.random(1,4)], 2},
  {random_potion_table[math.random(1,4)], 1},
  {random_potion_table[math.random(1,4)], 1},
}

local bracket1 = {
  {"normal_enemies/arborgeist_acorn", "normal_enemies/arborgeist_acorn",
    "normal_enemies/arborgeist_gust", "normal_enemies/arborgeist_gust"},
  {"normal_enemies/arborgeist_rogue","normal_enemies/arborgeist_rogue",},
  {"normal_enemies/frog", "normal_enemies/frog"},
  {"normal_enemies/cyclops_1", "normal_enemies/cyclops_1", "normal_enemies/cyclops_1", "normal_enemies/cyclops_1"},
  {"bosses/moss_boss", "normal_enemies/moss_bop", "normal_enemies/moss_bop"},
  prizeset = prizes1,
}

local bracket2 = {
  {"bosses/rock_spider_big", "bosses/rock_spider_big"},
  {"normal_enemies/skeleton_3","normal_enemies/skeleton_3","normal_enemies/skeleton_3"},
  {"normal_enemies/ogre_knight","normal_enemies/arborgeist_acorn",
      "normal_enemies/arborgeist_acorn","normal_enemies/arborgeist_acorn",},
  {"normal_enemies/mud_golem_1","normal_enemies/mud_golem_1","normal_enemies/mud_golem_1","normal_enemies/jellyfish"},
  {"bosses/charging_pirate_1", "normal_enemies/pirate_sword_brown_2","normal_enemies/pirate_sword_brown_2",},
  prizeset = prizes2,
}

local bracket3 = {
  {"bosses/burrow_crab_2","normal_enemies/triangle_crab_red","normal_enemies/triangle_crab_red","normal_enemies/triangle_crab_red",},
  {"normal_enemies/centipede","normal_enemies/centipede","normal_enemies/centipede",},
  {"bosses/rock_spider_fire","bosses/rock_spider_big","bosses/rock_spider_big","bosses/rock_spider_big"},
  {"bosses/fiend_1","bosses/fiend_1","bosses/fiend_1"},
  {"bosses/crow_mech", "normal_enemies/crowbot","normal_enemies/crowbot","normal_enemies/crowbot",},
  {"bosses/avalanche_golem","bosses/burrow_crab","normal_enemies/mud_golem_1","normal_enemies/mud_golem_1",},
  prizeset = prizes3,
}

local current_bracket
local current_phase = 1







--Arena Master Dude
function arenamaster:on_interaction()
  if current_bracket == nil then
    game:start_dialog("_oakhaven.npcs.port.underground.arenamaster.join", function(answer)
      if game:get_money() < 20 then game:start_dialog("_game.insufficient_funds")
      else
        if answer == 4 then return
        elseif answer == 1 then current_bracket = bracket1
        elseif answer == 2 then current_bracket = bracket2
        elseif answer == 3 then current_bracket = bracket3
        end
        game:start_dialog("_oakhaven.npcs.port.underground.arenamaster.gofight")
        game:remove_money(20)
        map:open_doors("arena_door")
      end
    end)
  else
    game:start_dialog("_oakhaven.npcs.port.underground.arenamaster.gofight")
  end
end

function map:load_enemies(bracket, phase)
  for i = 1, #bracket[phase] do
    local x,y,z = map:get_entity("enemy_spawner_" .. i):get_position()
    local enemy = map:create_enemy{
      x=x,y=y,layer=z,direction=3,
      name = "arena_enemy",
      breed = bracket[phase][i]
    }
    map:create_poof(enemy:get_position())
  end
end

--Sensor in center of arena
function arena_center_sensor:on_activated()
  if current_bracket and not map:has_entities("arena_enemy") then
    sol.audio.play_music"boss_battle"
    map:close_doors("arena_door")
    map:get_camera():shake()
    sol.audio.play_sound"cannon_fire"
    --check if that was the last phase
    if current_phase > #current_bracket then
      map:win_tournament()
    else
      map:load_enemies(current_bracket, current_phase)
      current_phase = current_phase + 1
    end

    --special cases
    if current_bracket == bracket1 and current_phase == 5 then sol.timer.start(map, 100, function()
      for e in map:get_entities_by_type("enemy") do
        if e:get_life() > 3 then e:set_life(3) end
      end
    end) end
    if current_bracket == bracket2 and current_phase == 4 then map:open_doors"arena_wall" end
    if current_bracket == bracket3 and current_phase == 2 then map:open_doors"arena_wall" end
  end
end

--Win!
function map:win_tournament()
  map:fade_in_music()
  map:open_doors("arena_door")
  map:close_doors("arena_wall")
  local x,y,z = arena_center_sensor:get_position()  
  local prizeset = current_bracket.prizeset
  for i = 1, #prizeset do
    map:create_pickable{
      x=x+math.random(-24,24),y=y+math.random(-24,24),layer=z,
      treasure_name = prizeset[i][1],
      treasure_variant = prizeset[i][2]
    }
  end
  current_bracket = nil
  current_phase = 1
end





