-- Lua script of map ballast_harbor/honestbeard.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local item_lander_x = 152
local item_lander_y = 128

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  if game:get_value("honestbeard_coral") == true then coral_ore_icon:set_enabled(false) end
  if game:get_value("honestbeard_armor") == true then armor_icon:set_enabled(false) end
  if game:get_value("honestbeard_armor_tools") == true then armor_tools_icon:set_enabled(false) end

end)



function honestbeard:on_interaction()
    game:start_dialog("_ballast_harbor.npcs.honestbeard.1")
end


--buy coral ore
function coral_ore_sale:on_interaction()
  if game:get_value("honestbeard_coral") ~= true then
    game:start_dialog("_ballast_harbor.npcs.honestbeard.coral_ore", function(answer)
      if answer == 3 then
        if game:get_money() >= 120 then
          hero:start_treasure("coral_ore")
          game:remove_money(120)
          game:set_value("honestbeard_coral", true)
          coral_ore_icon:set_enabled(false)
        else
          game:start_dialog("_game.insufficient_funds")
        end
      end
    end)
  else
  game:start_dialog("_ballast_harbor.npcs.honestbeard.out_of_coral")
  end
end

--buy armor
function armor_sale:on_interaction()
  if game:get_value("honestbeard_armor") ~= true then
    game:start_dialog("_ballast_harbor.npcs.honestbeard.armor", function(answer)
      if answer == 3 then
        if game:get_money() >= 150 then
          hero:start_treasure("armor_upgrade_2")
          game:remove_money(150)
          game:set_value("honestbeard_armor", true)
          armor_icon:set_enabled(false)
        else
          game:start_dialog("_game.insufficient_funds")
        end
      end
    end)
  else
  game:start_dialog("_ballast_harbor.npcs.honestbeard.out_of_coral")
  end
end

--buy armor tools
function tools_sale:on_interaction()
  if game:get_value("honestbeard_armor_tools") ~= true then
    game:start_dialog("_ballast_harbor.npcs.honestbeard.armor_tools", function(answer)
      if answer == 3 then
        if game:get_money() >= 250 then
          hero:start_treasure("armor_tools", 1, "found_armorer_tools_honestbeard")
          game:remove_money(250)
          game:set_value("honestbeard_armor_tools", true)
          armor_tools_icon:set_enabled(false)
        else
          game:start_dialog("_game.insufficient_funds")
        end
      end
    end)
  else
  game:start_dialog("_ballast_harbor.npcs.honestbeard.out_of_coral")
  end

end
