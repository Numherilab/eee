-- Lua script of map goatshead_island/interiors/CV_tavern.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()




function danley:on_interaction()
  --if you already killed the monster without prompting:
  if game:get_value("danley_convo_counter") == "special" then
    game:start_dialog("_goatshead.npcs.crabhook.tavern.danley.defeated_first", function()
      game:add_money(80)
      game:set_value("quest_crabhook_shoal_monster", 4) --quest log
    end)
    game:set_value("danley_convo_counter", 3)
  --if you haven't talked to danley before
  elseif game:get_value("danley_convo_counter") == nil then
    game:start_dialog("_goatshead.npcs.crabhook.tavern.danley.1", function(answer)
      if answer == 2 then
        game:start_dialog("_goatshead.npcs.crabhook.tavern.danley.2", function()
          game:set_value("danley_convo_counter", 1)
          game:set_value("looking_for_crabhook_monster", true)
          game:set_value("quest_crabhook_shoal_monster", 0) --quest log for monster quest started
        end)
      end
    end)
  elseif game:get_value("danley_convo_counter") == 1 then
    game:start_dialog("_goatshead.npcs.crabhook.tavern.danley.2")

  elseif game:get_value("danley_convo_counter") == 2 then
    game:start_dialog("_goatshead.npcs.crabhook.tavern.danley.3", function()
      game:add_money(80)
      game:set_value("quest_crabhook_shoal_monster", 4) --quest log
      game:set_value("looking_for_crabhook_monster", nil)
      game:set_value("danley_convo_counter", 3)
    end)

  elseif game:get_value("danley_convo_counter") == 3 then
    if game:get_value("phantom_squid_quest_complete") ~= true then
      game:start_dialog("_goatshead.npcs.crabhook.tavern.danley.4")
    else
      game:start_dialog("_goatshead.npcs.crabhook.tavern.danley.5")
    end
  end
end
