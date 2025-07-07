local map = ...
local game = map:get_game()
local hero = map:get_hero()


map:register_event("on_started", function()

  statue_treasure_chest:set_enabled(false)

--keep fountains on even if you die
  if game:get_value("shsf1") == true then
    torch_1:set_enabled(true)
    f1_1:set_enabled(true)
    f1_2:set_enabled(true)
    f1_3:set_enabled(true)
  end
  if game:get_value("shsf2") == true then
    torch_2:set_enabled(true)
    f2_1:set_enabled(true)
    f2_2:set_enabled(true)
    f2_3:set_enabled(true)
  end
  if game:get_value("shsf3") == true then
    torch_3:set_enabled(true)
    f3_1:set_enabled(true)
    f3_2:set_enabled(true)
    f3_3:set_enabled(true)
  end
  if game:get_value("shsf4") == true then
    torch_4:set_enabled(true)
    f4_1:set_enabled(true)
    f4_2:set_enabled(true)
    f4_3:set_enabled(true)
  end

--the you haven't initialized this value, do so now
  if game:get_value("spruce_head_shirine_num_fountains_activated") == nil then
    game:set_value("spruce_head_shirine_num_fountains_activated", 0)
  end

end)

--map banner
function map_banner_activator:on_activated()
  map:get_entity("^map_banner_sensor"):set_enabled(true)
  map_banner_activator:set_enabled(false)
end

--Skeleton note
function skeleton_note:on_interaction()
  --willow palace quest log instigation
  game:start_dialog("_ballast_harbor.observations.willow_palace_note", function()
    if not game:get_value"quest_willow_palace" then game:set_value("quest_willow_palace", 0) end
  end)
end


--Sail back to Ballast Harbor
function boat_sensor:on_activated()
  game:start_dialog("_ballast_harbor.observations.old_spruce_shrine_return", function(answer)
    if answer == 3 then
      hero:teleport("ballast_harbor/cave_1", "from_boat")
    end
  end)
end



function complete_dungeon_sensor:on_activated()
  if game:get_value"quest_willow_palace" == 1 then
    game:set_value("quest_willow_palace", 2)
  end
end



--cyclops battle
function miniboss:on_dead()
  sol.audio.play_sound("door_open")
  miniboss_door:set_enabled(false)
end




--central door
function central_door:on_interaction()
  if game:get_value("shsf1") == true
  and game:get_value("shsf2") == true
  and game:get_value("shsf3") == true
  and game:get_value("shsf3") == true then
    central_door:set_enabled(false)
    sol.audio.play_sound("switch_2")
    game:set_value("spruce_head_shrine_central_door", true)
  else
    game:start_dialog("_game.locked_door")
  end

end

--weak tree falling
function weak_tree_enemy:on_disabled()
  fall_tree_1:set_enabled(true)
  fall_tree_2:set_enabled(true)
  fall_tree_3:set_enabled(true)
end


--fountains
function fountain_switch_1:on_activated()
  if   game:get_value("shsf1") ~= true then
    game:set_value("spruce_head_shirine_num_fountains_activated", game:get_value("spruce_head_shirine_num_fountains_activated") +1 )
    if game:get_value"quest_willow_palace" == 0 then game.objectives:force_update() end
    torch_1:set_enabled(true)
    sol.audio.play_sound("switch_2")
    sol.audio.play_sound("water_flowing_in_2")end
    f1_1:set_enabled(true)
    f1_2:set_enabled(true)
    f1_3:set_enabled(true)
    game:set_value("shsf1", true)
    fountain_switch_1:set_locked(true)
    if game:get_value("shsf1") == true
    and game:get_value("shsf2") == true
    and game:get_value("shsf3") == true
    and game:get_value("shsf4") == true
    then sol.audio.play_sound("secret") map:open_central_door() end
end

function fountain_switch_2:on_activated()
  if   game:get_value("shsf2") ~= true then
    game:set_value("spruce_head_shirine_num_fountains_activated", game:get_value("spruce_head_shirine_num_fountains_activated") +1 )
    if game:get_value"quest_willow_palace" == 0 then game.objectives:force_update() end
    torch_2:set_enabled(true)
    sol.audio.play_sound("switch_2")
    sol.audio.play_sound("water_flowing_in_2")end
    f2_1:set_enabled(true)
    f2_2:set_enabled(true)
    f2_3:set_enabled(true)
    game:set_value("shsf2", true)
    fountain_switch_2:set_locked(true)
    if game:get_value("shsf1") == true
    and game:get_value("shsf2") == true
    and game:get_value("shsf3") == true
    and game:get_value("shsf4") == true
    then sol.audio.play_sound("secret") map:open_central_door() end
end

function fountain_switch_3:on_activated()
  if   game:get_value("shsf3") ~= true then
    game:set_value("spruce_head_shirine_num_fountains_activated", game:get_value("spruce_head_shirine_num_fountains_activated") +1 )
    if game:get_value"quest_willow_palace" == 0 then game.objectives:force_update() end
    torch_3:set_enabled(true)
    sol.audio.play_sound("switch_2")
    sol.audio.play_sound("water_flowing_in_2")end
    f3_1:set_enabled(true)
    f3_2:set_enabled(true)
    f3_3:set_enabled(true)
    game:set_value("shsf3", true)
    fountain_switch_3:set_locked(true)
    if game:get_value("shsf1") == true
    and game:get_value("shsf2") == true
    and game:get_value("shsf3") == true
    and game:get_value("shsf4") == true
    then sol.audio.play_sound("secret") map:open_central_door() end
end

function fountain_switch_4:on_activated()
  if   game:get_value("shsf4") ~= true then
    game:set_value("spruce_head_shirine_num_fountains_activated", game:get_value("spruce_head_shirine_num_fountains_activated") +1 )
    if game:get_value"quest_willow_palace" == 0 then game.objectives:force_update() end
    torch_4:set_enabled(true)
    sol.audio.play_sound("switch_2")
    sol.audio.play_sound("water_flowing_in_2")end
    f4_1:set_enabled(true)
    f4_2:set_enabled(true)
    f4_3:set_enabled(true)
    game:set_value("shsf4", true)
    fountain_switch_4:set_locked(true)
    if game:get_value("shsf1") == true
    and game:get_value("shsf2") == true
    and game:get_value("shsf3") == true
    and game:get_value("shsf4") == true
    then sol.audio.play_sound("secret") map:open_central_door() end
end

function map:open_central_door()
  map:focus_on(map:get_camera(), central_door, function()
    central_door:remove()
    game:set_value("spruce_head_shrine_central_door", true)
    game:set_value("quest_willow_palace", 1)
  end)
end



--secret statue switches
function statue_1:on_interaction()
  sol.audio.play_sound("switch")
  game:set_value("shsstatue_switch_1", true)
end

function statue_2:on_interaction()
  if game:get_value("shsstatue_switch_1") == true then
    sol.audio.play_sound("switch")
    game:set_value("shsstatue_switch_2", true)
  else
    game:set_value("shsstatue_switch_1", false)
    game:set_value("shsstatue_switch_2", false)
  end
end

function statue_3:on_interaction()
  if game:get_value("shsstatue_switch_2") == true then
    sol.audio.play_sound("switch")
    game:set_value("shsstatue_switch_3", true)
    boss_door:set_enabled(false)
    sol.audio.play_sound("secret")
  else
    game:set_value("shsstatue_switch_1", false)
    game:set_value("shsstatue_switch_2", false)
  end
end

--round 1 of secret switches
function statue_4:on_interaction()
  sol.audio.play_sound("switch")
  game:set_value("shsstatue_switch_4", true)
end

function statue_5:on_interaction()
  if game:get_value("shsstatue_switch_4") == true then
    sol.audio.play_sound("switch")
    game:set_value("shsstatue_switch_5", true)
  else
    game:set_value("shsstatue_switch_4", false)
    game:set_value("shsstatue_switch_5", false)
  end
end

function statue_6:on_interaction()
  if game:get_value("shsstatue_switch_5") == true then
    sol.audio.play_sound("switch")
    game:set_value("shsstatue_switch_6", true)
    statue_treasure_chest:set_enabled(true)
    sol.audio.play_sound("secret")
  else
    game:set_value("shsstatue_switch_4", false)
    game:set_value("shsstatue_switch_5", false)
  end
end