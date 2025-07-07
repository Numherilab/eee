local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  map:cloud_overlay()
  if game:get_value("kingsdown_island_unlocked") == true then
    block_statue_1:set_enabled(false)
    block_statue_2:set_enabled(false)
  end
end)

function tern_door_switch:on_activated()
  map:open_doors("tern_door")
end

function secret_keyhole:on_interaction()
  if game:has_item("key_kingsdown") and game:get_value("kingsdown_island_unlocked") ~= true then
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
