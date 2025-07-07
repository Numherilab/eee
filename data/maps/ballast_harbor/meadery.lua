-- Lua script of map ballast_harbor/meadery.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  michael_enemy:set_enabled(false)
  if (game:get_value("quest_briarwood_mushrooms") or 0) >= 4 then michael_npc:set_enabled(false) end

  if game:has_item("honeycomb") == true then
    benjamin:set_enabled(false)
  else
    benjamin_2:set_enabled(false)
  end

end)



--Michael Mead Maker
function michael_npc:on_interaction()
  if game:get_value("suspect_michael") == true then
    if game:get_value("bart_defeated") == true then
      game:start_dialog("_ballast_harbor.npcs.michael.3")
    else
      game:start_dialog("_ballast_harbor.npcs.michael.2")
    end
    michael_npc:set_enabled(false)
    michael_enemy:set_enabled(true)
  else
    game:start_dialog("_ballast_harbor.npcs.michael.1")
  end
end

function michael_enemy:on_dead()
  game:set_value("quest_briarwood_mushrooms", 4) --quest log, go back to distillery
  game:set_value("michael_defeated", true)
  game:set_value("rohit_dialog_counter", 6)

end



--Benjamin
function benjamin:on_interaction()
  if game:get_value("michael_defeated") == true then
    game:start_dialog("_ballast_harbor.npcs.benjamin.2", function()
      game:set_value("quest_ballast_harbor_hornet_honey", 0) --quest log
    end)
  else
    game:start_dialog("_ballast_harbor.npcs.benjamin.1", function()
      game:set_value("quest_ballast_harbor_hornet_honey", 0) --quest log
    end)
  end
end

function benjamin_2:on_interaction()
  if game:get_value("sold_honeycomb_to_benjamin") ~= true then
    if game:get_value("michael_defeated") == true then
      game:start_dialog("_ballast_harbor.npcs.benjamin.4", function()
        game:add_money(60)
        game:set_value("quest_ballast_harbor_hornet_honey", 2) --quest log
        end)
      game:set_value("sold_honeycomb_to_benjamin", true)
    else
      game:start_dialog("_ballast_harbor.npcs.benjamin.3", function()
        game:add_money(45)
        game:set_value("quest_ballast_harbor_hornet_honey", 2) --quest log
      end)
      game:set_value("sold_honeycomb_to_benjamin", true)
    end
  else
    game:start_dialog("_ballast_harbor.npcs.benjamin.5")
  end

end
