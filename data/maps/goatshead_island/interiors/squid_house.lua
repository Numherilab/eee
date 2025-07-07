-- Lua script of map goatshead_island/interiors/squid_house.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()


map:register_event("on_started", function()
  map:set_doors_open("front_door")

--enable characters
  aster_enemy:set_enabled(false)
  if game:get_value("barbell_brutes_defeated") then
    aster:set_enabled(false)
  end
  if game:get_value("aster_murdered") == true then
    aster:set_enabled(false)
    aster_2:set_enabled(false)
  end

  if game:get_value"quest_phantom_squid_contracts" then
    brassico:set_enabled(true)
    bowl:set_enabled(true)
  end

end)


--discover he's the squid
function secret_switch:on_interaction()
  secret_switch:remove()
  map:open_doors("secret_squid_head_door")
  sol.audio.play_sound("switch")
  if game:get_value("accepted_merchant_guild_contracts_quest") ~= true
  and game:get_value("aster_house_pressed_sesecret_switch") ~= true then
    --dialog and decide sides
    game:start_dialog("_goatshead.npcs.phantom_squid.3", function(answer)

      --side with Aster
      if answer == 2 then
        game:set_value("aster_house_pressed_sesecret_switch", true)
        game.objectives:set_alternate("phantom_squid", "quest.side.goatshead.phantom_squid_aster") --change to aster's version of the quest
        game:set_value("quest_phantom_squid", 3) --quest log, finish hunt squid quest
        --if you already have the contract
        if game:has_item("contract") == true then
          game:start_dialog("_goatshead.npcs.phantom_squid.5andahalf", function()
            game:set_value("accepted_merchant_guild_contracts_quest", true)
            game:set_value("talked_to_eamon", 2)
            game:set_value("goatshead_harbor_footprints_visible", false)
          end)
        --or if you didn't already find the contract:
        else
          game:start_dialog("_goatshead.npcs.phantom_squid.5", function()
            game:set_value("quest_phantom_squid_contracts", 0) --quest log, start part 2 of quest
            game:set_value("possession_aster_note", 1)

            game:set_value("accepted_merchant_guild_contracts_quest", true)
            game:set_value("talked_to_eamon", 2)
            game:set_value("goatshead_harbor_footprints_visible", false)
          end)
        end

      --side with Eamon
      else
        game:start_dialog("_goatshead.npcs.phantom_squid.4", function()
          aster:set_enabled(false)
          aster_enemy:set_enabled(true)
          map:close_doors("front_door")
          game:set_value("goatshead_harbor_footprints_visible", false)
          game:set_value("quest_phantom_squid", 2) --quest log, return to Eamon
        end)

      end
    end)
  end
end

--Aster, interactions until barbell brutes are defeated.
function aster:on_interaction()
  map:open_doors("front_door")
  --before you've even started his quest. Don't touch the bookshelf.
  if game:get_value("accepted_merchant_guild_contracts_quest") ~= true then
    game:start_dialog("_goatshead.npcs.phantom_squid.2")

  --once you've accepted the quest to help him, he's sent you to get the documents from Marchant HQ
  else
    --see if you have the contract yet
    if game:has_item("contract") ~= true then
      --don't have contract
      game:start_dialog("_goatshead.npcs.phantom_squid.6")
    else
      --have contract
      --tells you about the guards situation:
      if game:get_value("accepted_barbell_brute_quest") ~= true then
        map:eamon_appears()
      else --reminds you to fight guards
        game:start_dialog("_goatshead.npcs.phantom_squid.8") --reiterate, fight guards
      end

    end

  end
end

function map:eamon_appears()
  game:start_dialog("_goatshead.npcs.phantom_squid.7", function()
    hero:freeze()
    eamon:set_enabled()
    guard:set_enabled()
    hero:set_direction(3)
    local m2 = sol.movement.create"path"
    m2:set_path{2,2}
    m2:set_ignore_obstacles(true)
    m2:start(guard)
    local m = sol.movement.create"path"
    m:set_path{2,2,2,2,2,2,4,4}
    m:set_speed(65)
    m:set_ignore_obstacles(true)
    m:start(eamon, function()
      game:start_dialog("_goatshead.npcs.phantom_squid.7.2", function()
        m = sol.movement.create"target"
        m:set_speed(80)
        m:set_target(map:get_entity("aster_goal"))
        hero:freeze()
        m:start(aster, function()
          aster:get_sprite():set_direction(0)
          game:start_dialog("_goatshead.npcs.phantom_squid.7.3", function()
            hero:freeze()
            local m = sol.movement.create"path"
            m:set_path{0,0,6}
            m:set_speed(65)
            m:start(eamon, function()
              game:start_dialog("_goatshead.npcs.phantom_squid.7.4", function()
                map:eamon_part_2()
              end)
            end)
          end)
        end)
      end)
    end)
  end)
end

function map:eamon_part_2()
  local m2 = sol.movement.create"path"
  m2:set_path{6,6}
  m2:start(guard, function() guard:set_enabled(false) end)
  local m = sol.movement.create"path"
  m:set_path{6,6,6,6,6}
  m:start(eamon, function()
    eamon:set_enabled(false)
    game:start_dialog("_goatshead.npcs.phantom_squid.7.5", function()
        hero:unfreeze()
        game:set_value("accepted_barbell_brute_quest", true)
        game:set_value("quest_phantom_squid_contracts", 3) --quest log, go get oak charm
    end)
  end)
end


--Aster, after beating barbell brutes.
function aster_2:on_interaction()
  if game:get_value("phantom_squid_quest_completed") ~= true then
    game:start_dialog("_goatshead.npcs.phantom_squid.9", function()
      game:add_money(200)
      game:set_value("phantom_squid_quest_completed", true)
      game:set_value("quest_phantom_squid_contracts", 5) --quest log, end of quest
    end)
  else
    game:start_dialog("_goatshead.npcs.phantom_squid.10")
  end
end



function aster_enemy:on_dead()
  map:open_doors("front_door")
  game:set_value("aster_house_pressed_sesecret_switch", true)
  game:set_value("aster_murdered", true)
end

function brassico:on_interaction()
  if game:get_value("quest_phantom_squid_contracts") == 0 or game:get_value("quest_phantom_squid_contracts") == 1 then
    game:start_dialog"_goatshead.npcs.phantom_squid.brassico.1"

  elseif game:get_value("quest_phantom_squid_contracts") == 3 then
    game:start_dialog"_goatshead.npcs.phantom_squid.brassico.2"

  else
    game:start_dialog"_goatshead.npcs.phantom_squid.brassico.4"

  end
end

