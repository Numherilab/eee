-- Lua script of map goatshead_island/interiors/merchant_hq.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local guard_run

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  --enable entities
  if (game:get_value("quest_phantom_squid_contracts") or 0) >= 3 then eamon:set_enabled(false) end

  if (game:get_value("quest_phantom_squid_contracts") or 0) >= 4 then
    aster:set_enabled()
    aster:get_sprite():set_direction(2)
  end
  if (game:get_value"quest_phantom_squid_contracts" or 0) == 4 then eamon_exile:set_enabled(true) end

  --cutscene merchants
  if game:get_value"quest_phantom_squid_contracts" == 4 then
    for e in map:get_entities"cs_merch" do e:set_enabled() end
  end

  if (game:get_value("quest_phantom_squid_contracts") or 0) >=5 then merchant_hopeful:set_enabled() end

  

  if game:get_value("aster_murdered") == true  and game:get_value("phantom_squid_quest_completed") ~= true then
    eamon:set_enabled(false)
    eamon_winner:set_enabled(true)
  end

--movements
  guard_run = sol.movement.create("path")
  guard_run:set_path{4,4,4,4,4,4,4,4}
  guard_run:set_speed(80)
  guard_run:set_loop(false)
  guard_run:set_ignore_obstacles(true)

end)




--talking_to_eamon
function eamon:on_interaction()
--first time talking
  if game:get_value("talked_to_eamon") == nil then
    game:start_dialog("_goatshead.npcs.eamon.1", function(answer)
      if answer == 2 then
        game:start_dialog("_goatshead.npcs.eamon.2", function()
          game:set_value("quest_phantom_squid", 0) --quest log, accept quest
        end)
        game:set_value("talked_to_eamon", 1)
        game:set_value("phantom_squid_quest_accepted", true)
      end
    end)

  --haven't done anything yet
  elseif game:get_value("talked_to_eamon") == 1 then
    game:start_dialog("_goatshead.npcs.eamon.3")

  --accepted Aster's quest
  elseif game:get_value("talked_to_eamon") == 2 then
    game:start_dialog("_goatshead.npcs.eamon.4", function()
      game:add_money(10)
      game:set_value("talked_to_eamon", 3)
    end)

  elseif game:get_value("talked_to_eamon") == 3 then
    game:start_dialog("_goatshead.npcs.eamon.5")

  end
end

--if you killed Aster
function eamon_winner:on_interaction()
  if game:get_value("taken_eamons_reward") ~= true then
    game:start_dialog("_goatshead.npcs.eamon.killed_astor.1", function()
      game:add_money(60)
      game:set_value("taken_eamons_reward", true)
      game:set_value("quest_phantom_squid", 3)
    end)
  else
    game:start_dialog("_goatshead.npcs.eamon.killed_astor.2")
  end
end


--Eamon ousting
function eamon_exile_sensor:on_activated()
  if game:get_value"quest_phantom_squid_contracts" == 4 and not map.trapped_in_exile_meeting then
    map.trapped_in_exile_meeting = true
    hero:freeze()
    hero:set_animation"walking"
    local m = sol.movement.create"target"
    m:set_target(map:get_entity"hero_target_ousting_scene")
    m:set_speed(80)
    m:start(hero, function()
      hero:set_animation"stopped"
      m = sol.movement.create"path"
      m:set_path{4}
      m:start(cs_merch_1)
      game:start_dialog("_goatshead.npcs.merchants_guild.ousting_scene.1", function()
        m = sol.movement.create"path"
        m:set_path{2,2,2,2,2,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4}
        m:set_speed(70)
        m:set_ignore_obstacles()
        m:start(eamon_exile, function()
          eamon_exile:set_enabled(false)
          hero:unfreeze()
        end)
      end)
    end)

  elseif map.trapped_in_exile_meeting then
    game:start_dialog("_goatshead.observations.should_talk_to_aster", function()
      hero:walk"0000"
    end)

  end
  
end

function aster:on_interaction()
  if game:get_value"quest_phantom_squid_contracts" == 4 then
    map.trapped_in_exile_meeting = false
    game:start_dialog("_goatshead.npcs.merchants_guild.ousting_scene.aster", function()
      game:set_value("quest_phantom_squid_contracts", 5)
      game:set_value("phantom_squid_quest_completed", true)
      game:add_money(200)
    end)
  else
    game:start_dialog"_goatshead.npcs.phantom_squid.11"
  end
end


--study door
local switch_index = 1
local switches = {"study_switch_2", "study_switch_3", "study_switch_1", "study_switch_4", "study_switch_2"}

for entity in map:get_entities("study_switch_") do
  function entity:on_interaction()
    map:process_switch(self:get_name())
  end
end

function map:process_switch(name)
  map:get_camera():shake({count=4, amplitude=1, zoom_factor=1})
  if switch_index and switches[switch_index] == name then
    map:get_camera():shake({count=4, amplitude=2, zoom_factor=1})
    switch_index = switch_index + 1
    --show some feedback here so they player knows they did something
    sol.audio.play_sound"switch"
    if switch_index == (#switches + 1) then
      --do whatever happens when you do all the things in the right order:
      sol.audio.play_sound"switch_2"
      sol.audio.play_sound"hero_pushes"
      for entity in map:get_entities"study_door" do
        local m = sol.movement.create"straight"
        m:set_max_distance(16)
        m:set_angle(0)
        m:set_ignore_obstacles(true)
        m:start(entity)
      end
    end

  else
    --if the player hits one out of order:
    sol.audio.play_sound"wrong"
    switch_index = 1
  end
end
