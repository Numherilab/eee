local map = ...
local game = map:get_game()

function letter:on_interaction()
  game:start_dialog("_yarrowmouth.observations.safehouse_letter", function()
    if game:get_value("rohit_dialog_counter") >= 2 and game:get_value("rohit_dialog_counter") < 4 then
      game:set_value("rohit_dialog_counter", 4)
      game:set_value("suspect_michael", true)
      game:set_value("quest_briarwood_mushrooms", 2)
    end
  end)
  if game:get_value("puzzlewood_footprints_visible") == true then game:set_value("puzzlewood_footprints_visible", false) end
end
