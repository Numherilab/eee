local map = ...
local game = map:get_game()

function map:on_started()
  sol.achievements.unlock("ach_thorn_monk")
end

function monk:on_interaction()
  if game:get_item("spear"):get_variant() < 2 then
    game:start_dialog"_oakhaven.npcs.thorn_monk.1"
    game:set_value"talked_to_thorn_monk"
  elseif not game:get_value"sunflower_spear_upgrade" then
  --have sunflower spear, not upgraded
    if game:get_value"talked_to_thorn_monk" then
      game:start_dialog"_oakhaven.npcs.thorn_monk.2_seen_before"
    else
      game:start_dialog"_oakhaven.npcs.thorn_monk.2_new_here"
    end
      game:set_value("sunflower_spear_upgrade", true)
  elseif game:get_value"sunflower_spear_upgrade" then
  --spear is upgraded
    game:start_dialog"_oakhaven.npcs.thorn_monk.4"
  end
end
