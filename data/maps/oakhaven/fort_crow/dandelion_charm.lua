local map = ...
local game = map:get_game()

function spirit:on_interaction()
  if game:get_value("have_dandelion_charm") ~= true then
    game:start_dialog("_goatshead.npcs.spirits.1", function()
      hero:start_treasure("dandelion_charm")
      game:set_value("have_dandelion_charm", true)
    end)

  else
    game:start_dialog("_goatshead.npcs.spirits.2")
  end
end
