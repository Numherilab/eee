-- Lua script of map oakhaven/gull_rock.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()

map:register_event("on_started", function()
  map:cloud_overlay()
  --put Hazel Ally on the map
  if game:get_value("hazel_is_currently_following_you") and game:get_value("spoken_to_hazel_south_gate") then
    require("scripts/action/hazel_ally"):summon(hero)
  end
  if game:has_item("sword_of_the_sea_king") and game:get_value("quest_mangrove_sword") < 4 then
    hazel_npc:set_enabled(true)
  end
end)

function mangrove_sensor:on_activated()
  if game:get_value("quest_mangrove_sword") and game:get_value("quest_mangrove_sword") < 2 then
    game:set_value("quest_mangrove_sword", 2)
  end
  mangrove_sensor:set_enabled(false)
end

--Hazel NPC
function hazel_npc:on_interaction()
  if game:get_value("quest_mangrove_sword") < 4 then
    game:start_dialog("_oakhaven.npcs.hazel.thicket.4")
  elseif game:get_value("quest_mangrove_sword") >= 4 then

  end
end

--Sword of the Sea King Cutscene
function mangrove_scene_sensor:on_activated()
  if game:get_value("hazel_is_currently_following_you") and game:get_value("spoken_to_hazel_south_gate") then
    hero:freeze()
    game:start_dialog("_oakhaven.npcs.hazel.thicket.2", function()
      hazel:stop_movement()
      hazel_npc:set_position(hazel:get_position())
      hazel_npc:set_enabled(true)
      hazel:set_enabled(false)
      local m = sol.movement.create("target")
      m:set_target(776, 413)
      m:set_ignore_obstacles()
      m:start(hazel_npc, function()
        hazel_npc:get_sprite():set_direction(1)
        game:start_dialog("_oakhaven.npcs.hazel.thicket.3", function()
          sol.audio.play_sound"charge_sword"
          sol.audio.play_sound"crackle1"
          local dimming_iterations = 0
          sol.timer.start(map, 25, function()
            map:get_camera():get_surface():set_color_modulation{
              255-dimming_iterations*5,
              255-dimming_iterations*8,
              255-dimming_iterations*15}
            dimming_iterations = dimming_iterations + 1
            if dimming_iterations <= 10 then return true end
          end)
          local dx,dy,dz = mangrove_door:get_position()
          for i=1, 8 do
            local leaf_effect = map:create_custom_entity{
              x=dx-30+10*i,y=dy+math.random(-16,16),layer=dz+1,
              direction=0,width=16,height=16,
              sprite="entities/bush",model="ephereral_effect",}
            leaf_effect:get_sprite():set_animation("destroy")
            leaf_effect:get_sprite():set_blend_mode"add"
          end
          map:open_doors("mangrove_door")
          game:set_value("hazel_is_currently_following_you", false)
          game:set_value("quest_mangrove_sword", 3)
          hero:unfreeze()
        end)
      end)
    end)
  end
end

function wrapup_cutscene_sensor:on_activated()
  wrapup_cutscene_sensor:set_enabled(false)
  if game:has_item("sword_of_the_sea_king") and game:get_value("quest_mangrove_sword") < 4 then
    game:set_value("quest_mangrove_sword", 4)
    game:set_value("morus_available", true)
    game:start_dialog("_oakhaven.npcs.hazel.thicket.5", function(answer)
      if answer == 2 then
        game:start_dialog("_oakhaven.npcs.hazel.thicket.6", function()
          hero:teleport("oakhaven/oakhaven", "from_saloon")
          game:set_value("quest_pirate_fort", 0)
        end)
      elseif answer == 3 then
        game:start_dialog("_oakhaven.npcs.hazel.thicket.7", function()
          game:set_value("quest_pirate_fort", 0)
        end)
      end
    end)
  end
end