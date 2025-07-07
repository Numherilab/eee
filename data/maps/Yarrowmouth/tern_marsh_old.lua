-- Lua script of map Yarrowmouth/kingsdown.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  if game:get_value("kingsdown_island_unlocked") == true then
    block_statue_1:set_enabled(false)
    block_statue_2:set_enabled(false)
  end

  if game:get_value("yarrow_village_pirate_guard_left") == true then pirate_guard:set_enabled(false) end

  if game:get_value("nina_dialog_counter") ~= 2 then nina:set_enabled(false) end

end)


function secret_keyhole:on_interaction()
  if game:has_item("key_kingsdown") == true and game:get_value("kingsdown_island_unlocked") ~= true then
    game:start_dialog("_yarrowmouth.observations.secret_switch.2", function(answer)
      if answer == 3 then
        local x, y, l = block_statue_1:get_position()
        map:create_poof(x + 8, y + 16, l + 1)
        block_statue_1:set_enabled(false)
        block_statue_2:set_enabled(false)
        sol.audio.play_sound("switch")
        sol.audio.play_sound("secret")
          game:set_value("kingsdown_island_unlocked", true)
          game:set_value("quest_log_a", "a7")
          game:set_value("quest_log_b", 0)
          if game:get_value("quest_hourglass_fort") == 1 then
            game:set_value("quest_hourglass_fort", 2) --quest log
          end
          game:set_value("quest_kelpton", 5) -- quest log

      end
    end) --end of answer function

  else --don't have the key yet
    game:start_dialog("_yarrowmouth.observations.secret_switch.1")

  end
end

function hourglass_bridge_switch:on_activated()
  map:open_doors("hourglass_door")
end

function door_item_sensor:on_activated()
  if not game:has_item("heron_door_tern_marsh") then
    game:get_item("heron_door_tern_marsh"):set_variant(1)
    game:set_value("found_heron_door_tern_marsh", 1) --TODO quest log issue #76
    game.objectives:force_update() --TODO quest log issue #70
  end
end



function pirate_guard:on_interaction()
  if game:get_value("going_to_meet_carlov_pirates") == true then
    game:start_dialog("_yarrowmouth.npcs.guard_pirate.2")
    local m = sol.movement.create("path")
    m:set_path{2,2,2}
    m:set_speed(40)
    m:set_speed(20)
    m:set_ignore_obstacles(true)
    m:start(pirate_guard, function()
--      sol.timer.start(map, 1000, function() pirate_guard:set_enabled(false) end)
      pirate_guard:set_enabled(false)
      game:set_value("yarrow_village_pirate_guard_left", true)
    end)

  else --if you haven't already talked to Nina
    game:start_dialog("_yarrowmouth.npcs.guard_pirate.1")
  end
end


function nina:on_interaction()
  if game:get_value("nina_dialog_counter") == 2 then
    game:start_dialog("_yarrowmouth.npcs.nina.marsh1", function()
      game:set_value("nina_dialog_counter", 3)
      game:set_value("quest_yarrow_parley", 3) --quest log
    end)

  elseif game:get_value("nina_dialog_counter") == 3 then
    game:start_dialog("_yarrowmouth.npcs.nina.6")
  end

end
