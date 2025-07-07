local map = ...
local game = map:get_game()

local ophira = map:get_entity"^lighting_effect_torch_ophira"

map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(2)
  sol.menu.start(map, lighting_effects)

  sword:set_drawn_in_y_order(true)

  map:set_doors_open"boss_door"

 game:set_value("fykonos_seen_ophira", true) --this is so the demo doesn't do init values if loading save from boss starting location

  if game:has_item"limestone_sword" then
--    sword:set_enabled(false)
--    boss_start_sensor:set_enabled(false)
  end
end)





function boss_start_sensor:on_activated()
 boss_start_sensor:remove()
 game:start_dialog("_fykonos.observations.tomb.see_sword", function()
  map:focus_on(map:get_camera(), sword, function()
    map:create_poof(ophira:get_position())
    ophira:set_enabled()
    map:sword_chain_attack()
    sol.audio.play_music"boss_battle"
    map:close_doors"boss_door"
  end)

  --Periodic Sword Chain Attack
  sol.timer.start(map, 5000, function()
    if ophira:get_life() <= 0 then return false end
    sol.audio.play_sound"charge_3"
    sol.timer.start(map, 600, function()
      map:sword_chain_attack()
    end)
    return math.random(6000, 10000)
  end)
 end)
end



function ophira:on_dead()
  sol.audio.stop_music()
  map:focus_on(map:get_camera(), sword, function()
    get_sword_sensor:set_enabled(true)
  end)
end


function get_sword_sensor:on_activated()
  get_sword_sensor:remove()
  sword:set_enabled(false)
  game:get_item("sword"):set_variant(1)
  hero:start_treasure("limestone_sword", 1, nil, function()
    map:open_doors"boss_door"
    map:blackbeard_scene()
  end)
end



local cutscene_freeze
function map:blackbeard_scene()
  cutscene_freeze = true
  sol.timer.start(map, 100, function()
    if cutscene_freeze then
      hero:freeze()
      hero:set_direction(hero:get_direction4_to(blackbeard))
      return true
    end
  end)
  hero:set_direction(3) 
  hero:freeze()
  game:get_dialog_box():set_position("bottom")
    blackbeard:set_enabled(true)
    map:get_camera():start_tracking(blackbeard)
    local m = sol.movement.create"path"
    m:set_path{2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2}
    m:set_speed(70)
    m:start(blackbeard, function()
      game:start_dialog("_fykonos.npcs.blackbeard.1", function()
        m:set_path{4,4,4,4,4,4,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2,2,2,2}
        m:start(blackbeard, function()
          sol.timer.start(map, 1000, function()
            game:start_dialog("_fykonos.npcs.blackbeard.heheheh", function()
              if game:get_value"fykonos_not_demo" then
                map:blackbeard_scene_2_full_game()
              else
                map:blackbeard_scene_2_demo()
              end
            end)
          end)
        end)
      end)
    end)

end

function map:blackbeard_scene_2_demo()
  hero:set_visible(false)
  game:get_hud():set_enabled(false)
  hero:teleport("fykonos/zzz_end")
  game:start_dialog("_fykonos.npcs.blackbeard.to_be_contd", function()
    sol.timer.start(sol.main, 20, function() sol.main.reset() end)
  end)
end

function map:blackbeard_scene_2_full_game()
  local x, y, z = blackbeard:get_position()
  map:create_custom_entity{
    x=x, y=y, layer=z, width=16, height=16, direction=1, sprite="enemies/misc/sword_slash", model="ephereral_effect"
  }
  blackbeard:get_sprite():set_animation("attack", "stopped")
  sol.audio.play_sound"sword2"
  for e in map:get_entities"obscuring_vines" do
    e:remove()
  end
  map:get_entity("^lighting_effect_candle_statue"):set_enabled()
  sol.timer.start(map, 1000, function()
    game:start_dialog("_fykonos.npcs.blackbeard.2", function()
      local m = sol.movement.create"path"
      m:set_path{6,6,6,6,6,6,6,6,6,6,6,6}
      m:set_speed(70)
      m:start(blackbeard, function()
        game:start_dialog("_fykonos.npcs.blackbeard.3", function()
          game:set_value("fykonos_defeated_ophira", true)
          m:set_path{0,0,0,0,0,0,0,0,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,4,4,4,4,4,4,4,4,6,6,6,6,6,6,6,6,6,6,6,6,6,6}
          m:start(blackbeard, function()
            blackbeard:set_enabled(false)
            map:get_camera():start_tracking(hero)
            cutscene_freeze = false
            map:fade_in_music()
            hero:unfreeze()
            game:set_value("quest_fykonos", 2)
            if game:get_value"dialog_size_mode" == "big" then game:get_dialog_box():set_position("auto") end
          end)
        end)
      end)
    end)
  end)
end






---------------------Sword Chain Attack---------------------------------


function map:sword_chain_attack()
  local se_reps = 1
  sol.timer.start(map, 110, function()
    sol.audio.play_sound"rupee_counter"
    if se_reps < 8 then se_reps = se_reps + 1 return true end
  end)

  local NUM_CHAINS = 5
  for i=1, NUM_CHAINS do
    local angle = (math.pi*2 / NUM_CHAINS) * i
    local x,y,z = sword:get_position()
    local spreader = map:create_custom_entity{x=x,y=y,layer=z,width=16,height=16,direction=0}
    local m = sol.movement.create"straight"
    m:set_smooth(false)
    m:set_speed(200)
    m:set_angle(angle)
    m:start(spreader, function() spreader:remove() end)
    function m:on_obstacle_reached() spreader:remove() end

    local timer = sol.timer.start(map, 30, function()
      x,y,z = spreader:get_position()
      local link = map:create_enemy{x=x,y=y,layer=z,direction=0,breed="misc/enemy_weapon"}
      link:create_sprite("enemies/bosses/ophira_chain_link")
      sol.timer.start(link, 1000, function()
        link:get_sprite():set_animation("disappearing", function() link:remove() end)
      end)
      if spreader:exists() then return true
      end
    end)

  end
end
