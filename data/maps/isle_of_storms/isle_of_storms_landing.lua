-- Lua script of map isle_of_storms/landing.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = game:get_hero()
local sound_atmosphere_manager = require("scripts/fx/sound_atmosphere_manager")

local white_surface = sol.surface.create()
  white_surface:fill_color({255,255,255})
  white_surface:set_opacity(0)
local black = sol.surface.create()
black:fill_color{0,0,0}
black:set_opacity(0)

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
  sound_atmosphere_manager:start_atmosphere(map, "rain")
  local world = map:get_world()
  game:set_world_rain_mode(world, "storm")
  local rain_manager = require("scripts/weather/rain_manager")
  rain_manager:set_storm_speed(300)
  rain_manager:set_lightning_delay(2000, 7500)
  rain_manager:set_darkness(20, 90)

  map:set_doors_open("boss_door")
  for cannon in map:get_entities("blackbeard_ship_cannon") do
    cannon.shooting_disabled = true
    cannon.projectile_breed = "misc/bomb_4_direction"
  end

  if game:get_value("quest_isle_of_storms") and game:get_value("quest_isle_of_storms") < 1 then
    game:set_value("quest_isle_of_storms", 1)
  end
  if game:get_value("sea_king_defeated") then
    rune_sensor:set_enabled(false)
    for e in map:get_entities("broken_ship") do e:set_enabled(true) end
  end
  brutus:get_sprite():set_animation("stopped")
  if game:get_value("quest_isle_of_storms") and game:get_value("quest_isle_of_storms") >= 2 then
    brutus:set_enabled(false)
    brutus_sensor:set_enabled(false)
  end
  if game:get_value("quest_isle_of_storms") and game:get_value("quest_isle_of_storms") >= 4 then
    map:set_doors_open("preboss_door")
  end

end)

function map:on_draw(dst)
  white_surface:draw(dst)
  black:draw(dst)
end

--[[
function morus:on_interaction()
  game:start_dialog("_oakhaven.npcs.morus.ferry_2", function(answer)
    if answer == 1 then
      hero:teleport("oakhaven/port", "morus_landing")
    elseif answer == 2 then
      hero:teleport("snapmast_reef/snapmast_landing", "ferry_landing")
    elseif answer == 3 then
      game:start_dialog("_oakhaven.npcs.morus.ferry_already")
    end
  end)
end
--]]

----------------Sensors--------------------------------------
function brutus_sensor:on_activated()
  if game:get_value("quest_isle_of_storms") and game:get_value("quest_isle_of_storms") < 2 then
    hero:freeze()
    local m=sol.movement.create("path")
    m:set_path{6,6,6,6,6,6}
    m:start(brutus, function()
      game:start_dialog("_palace_of_storms.cutscenes.brutus.1")
      game:set_value("quest_isle_of_storms", 2)
      hero:unfreeze()
    end)
  end
end

function blackbeard_sensor:on_activated()
  if game:get_value("quest_isle_of_storms") and game:get_value("quest_isle_of_storms") == 3 then
    hero:freeze()
    local m = sol.movement.create"path"
    m:set_path{6,6,6,6,6,6,6,6,6,6,6,6,6,6}
    m:set_speed(90)
    hero:set_animation"walking"
    m:start(hero, function()
      hero:set_animation"stopped"
      sol.timer.start(map, 1000, function()
        blackbeard_npc:set_enabled(true)
        sol.audio.play_sound"warp"
        map:create_poof(blackbeard_npc:get_position())
        sol.timer.start(map, 800, function()
          game:start_dialog("_palace_of_storms.cutscenes.blackbeard.1", function()
            hero:set_direction(1)
            mallow:set_enabled(true)
            local m2 = sol.movement.create"path"
            m2:set_path{2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,4,4,4,2,2}
            m2:set_speed(80)
            m2:start(mallow, function()
              map:blackbeard_return_scene_2()
            end)
          end)
        end)
      end)
    end)
  end
end
function map:blackbeard_return_scene_2()
  game:start_dialog("_palace_of_storms.cutscenes.blackbeard.2", function()
    map:create_poof(blackbeard_npc:get_position())
    blackbeard_npc:set_enabled(false)
    sol.audio.play_sound"warp"
    sol.timer.start(map, 1000, function()
      mallow:get_sprite():set_animation("grinning")
      game:start_dialog("_palace_of_storms.cutscenes.mallow.4-5", function()
        mallow:get_sprite():set_animation("teetering")
        sol.timer.start(map, 1300, function()
          sol.audio.play_sound"thunk1"
          mallow:get_sprite():set_animation("collapsed")
          game:start_dialog("_palace_of_storms.cutscenes.mallow.5", function()
            game:set_value("quest_isle_of_storms", 4)
            map:open_doors("preboss_door")
            hero:unfreeze()
          end)
        end)
      end)
    end)
  end)
end

function save_sensor:on_activated()
  if map.bb_defeated then return end
  game:start_dialog("_palace_of_storms.observations.final_battle_save", function(answer)
    if answer == 3 then
      game:set_respawn_point()
      game:save()
      sol.audio.play_sound("elixer_upgrade")
    end
  end)
  save_sensor:remove()
end


---Teleport Down to Ruins
function rune_sensor:on_activated()
  hero:freeze()
  hero:set_direction(3)
  sol.audio.play_sound("sea_spirit")
  sol.audio.play_sound("charge_1")
  sol.audio.play_sound("warp")
  rune:set_enabled(true)
  white_surface:fade_in(150, function()
    hero:teleport("isle_of_storms/palace", "portal_to_surface")
  end)
end


--------BOSS------------
function boss_sensor:on_activated()
  boss_sensor:set_enabled(false)
  map:close_doors("boss_door")
  hero:freeze()
  hero:set_animation"walking"
  local m=sol.movement.create"path" m:set_path{2,2,2,2,2,2,2,2,2,2} m:set_speed(80)
  m:start(hero, function()
    game:start_dialog("_palace_of_storms.cutscenes.blackbeard.3", function()
      hero:unfreeze()
      dummybeard:set_enabled(false)
      blackbeard_boss:set_enabled(true)
    end)
  end)
end

function blackbeard_boss:on_dead()
  hero:freeze()
  map.bb_defeated = true
  --you're not really playing after this point, so
  game:set_pause_allowed(false)
  sol.audio.stop_music()
  hero:set_animation("walking")
  local m = sol.movement.create("target") m:set_target(boss_teleport_ref)
  m:start(hero, function()
    hero:set_direction(3)
    hero:set_animation"stopped"
    local x,y,l=hero:get_position()
    local oceans_heart = map:create_custom_entity{
      x=x,y=y-200,layer=l+2,direction=0,width=16,height=16,sprite="entities/oceans_heart"
    }
    local m2=sol.movement.create"straight"
    m2:set_max_distance(216) m2:set_angle(math.pi*3/2)
    m2:start(oceans_heart, function()
      sol.timer.start(map, 2000, function()
        game:start_dialog("_palace_of_storms.observations.smash_heart", function()
          sol.timer.start(map, 1000, function()
            hero:unfreeze()
            hero:start_attack()
            sol.timer.start(map, 500, function() hero:freeze() end)
            sol.audio.play_sound"breaking_glass"
            game:set_life(game:get_max_life())
            game:set_world_rain_mode(map:get_world(), nil)
            sound_atmosphere_manager:stop_sounds()
            oceans_heart:get_sprite():set_animation("shatter", function() oceans_heart:remove() end)
            game:set_value("quest_isle_of_storms", 5)
            endgame_mallow:set_enabled(true)
            sol.timer.start(map, 2000, function()
              map:open_doors("boss_door")
              sol.achievements.unlock("ach_kill_blackbeard")
              if game:get_value("hard_mode") then sol.achievements.unlock("ach_cursed_blackbeard") end
              if not game:get_value("stepped_foot_in_spruce_head") then sol.achievements.unlock("ach_skip_spruce_head") end
              hero:unfreeze()
            end)
          end)
        end)
      end)
    end)
  end)
  sol.timer.start(map, 10, function() hero:set_direction(m:get_direction4()) end)
end



---------Endgame-------------
function endgame_sensor:on_activated()
  if game:get_value("quest_isle_of_storms") == 5 then
    hero:freeze()
    hero:set_animation"walking"
    local m = sol.movement.create"path"
    m:set_path{4,4,4,4,4,4,4,4,4}
    m:start(hero, function()
      hero:set_animation"stopped"
      game:start_dialog("_palace_of_storms.cutscenes.mallow.6", function()
        game:get_hud():set_enabled(false)
        black:fade_in(80, function() hero:teleport("dummy_cutscene/oakhaven_scroll") end)
      end)
    end)
  end
end