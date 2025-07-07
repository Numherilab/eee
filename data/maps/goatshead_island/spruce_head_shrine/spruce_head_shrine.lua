-- Lua script of map goatshead_island/spruce_head_shrine/spruce_head_shrine.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()


map:register_event("on_started", function()
  game:set_world_fall_mode(map:get_world(), "fall")

  map:set_doors_open("d4_door")
  map:set_doors_open"boss_door"
  if game:get_value"quest_spruce_head" or game:get_value"shh_talked_to_ilex" then
    map:set_doors_open"entry_door"
  end
  if game:get_value("ssh_boss_defeated") then
    boss:set_enabled(false)
    boss_health_chest:set_enabled()
    for w in map:get_entities"boss_wall" do
      w:set_enabled(false)
    end
  end
  --miniboss is REALLY unforgiving if you don't raise your stats, so we'll cheat
  if game:get_value("defense") < 4 then miniboss:set_damage(1) end

end)


--NPCs and Stuff------------------------------------------

function ilex:on_interaction()
  if not game:get_value("quest_spruce_head") then
    game:start_dialog"_goatshead.npcs.ilex_new.0"
  elseif game:get_value"quest_spruce_head" == 1 then
    game:start_dialog"_goatshead.npcs.ilex_new.2"
  elseif game:get_value"quest_spruce_head" == 2 then
    game:start_dialog"_goatshead.npcs.ilex_new.3"
  else
    game:start_dialog"_goatshead.npcs.ilex_new.4"
  end
end

function captain_log:on_interaction()
  if game:get_value"quest_spruce_head" == 1 then
    game:start_dialog("_goatshead.observations.spruce_captain_log.1", function()
--      game:set_value("seen_spruce_sanctuary", true)
      game:set_value("quest_spruce_head", 2)
      hero:teleport("stonefell_crossroads/spruce_head", "from_shrine")
    end)
  else
    game:start_dialog("_goatshead.observations.spruce_captain_log.2")
  end
end


--Switches-------------------------------------------------
function b6_switch:on_activated()
  sol.audio.play_sound"switch"
  map:open_doors"door_b6_posts"
end

for switch in map:get_entities"b1_switch" do
  function switch:on_activated()
    map:open_doors"b1_door"
    sol.timer.start(map, 200, function()
      for other_switch in map:get_entities"b1_switch" do
        if not other_switch:is_activated() then
          switch:set_activated(false)
          map:close_doors"b1_door"
        end
      end
    end)
  end
end

function d6_switch:on_activated()
  sol.audio.play_sound"switch"
  map:open_doors"d6_door"
end



--Sensors--------------------------------------------------
function ilex_sensor:on_activated()
  game:set_value("stepped_foot_in_spruce_head", true)
  if game:get_value"quest_spruce_head" and not game:get_value"shh_talked_to_ilex" then
    hero:freeze()
    hero:walk("2224422")
    sol.timer.start(map, 600, function()
      hero:freeze()
      game:start_dialog("_goatshead.npcs.ilex_new.1", function()
        game:set_value("shh_talked_to_ilex", true)
        game:set_value("quest_spruce_head", 1)
        hero:unfreeze()
      end)
    end)
  end
end

function miniboss_sensor:on_activated()
  for e in map:get_entities("miniboss_wall") do
    e:set_enabled(false)
  end
  if not game:get_value("ssh_miniboss_defeated") then
    map:close_doors("d4_door")
    miniboss_sensor:set_enabled(false)
  end
end

function boss_sensor:on_activated()
  if not game:get_value"ssh_boss_defeated" then
    boss_sensor:set_enabled(false)
    map:close_doors"boss_door"
    sol.audio.play_music"boss_battle"
    for w in map:get_entities"boss_wall" do
      w:set_enabled(false)
    end
  end
end



--Enemies--------------------------------------------------

function a4_gargoyle:on_dead()
  sol.audio.play_sound"secret"
  map:open_doors("a4_door")
end

  --Miniboss--
function miniboss:on_dead()
  map:open_doors("d4_door")
  map:open_doors("c4_door")
  d4_chest:set_enabled(true)
  game:set_value("ssh_miniboss_defeated", true)
  map:create_poof(d4_chest:get_position())
  sol.audio.play_sound"secret"
end

  --Boss--
function boss:on_dying()
  for e in map:get_entities("boss_ball") do
    e:remove()
  end
end

function boss:on_dead()
  for e in map:get_entities("boss_ball") do
    e:remove()
  end
  map:fade_in_music()
  game:set_value("ssh_boss_defeated", true)
  boss_health_chest:set_enabled()
  map:create_poof(boss_health_chest:get_position())
  map:open_doors"boss_door"
  if map:has_entities"minion_boss" then
    for e in map:get_entities"minion_boss" do
      e:hurt(20)
    end
  end
end


