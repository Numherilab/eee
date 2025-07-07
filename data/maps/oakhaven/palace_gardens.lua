-- Lua script of map oakhaven/palace_gardens.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  if game:get_value("quest_mayors_dog") and game:get_value("quest_mayors_dog") >= 7 and game:get_value("quest_mayors_dog") < 11 then
    happy_mayor:set_enabled(false)
    sad_mayor:set_enabled(true)
    dog:set_enabled(false)
  end
end)

function happy_mayor:on_interaction()
  if game:get_value("quest_mayors_dog") <= 6 then
    game:start_dialog("_oakhaven.npcs.mayors_party.mayor.1")

  elseif game:get_value("quest_mayors_dog") > 10 then
    if not game:has_item("key_to_oakhaven") then
      game:start_dialog("_oakhaven.npcs.mayors_party.mayor.3", function()
        hero:start_treasure("key_to_oakhaven")
      end)
    else game:start_dialog("_oakhaven.npcs.mayors_party.mayor.4") end
    
  end
end

function dog:on_interaction()
  if game:get_value("quest_mayors_dog") < 10 then
    game:start_dialog("_oakhaven.npcs.mayors_party.dog.1")
  else
    game:start_dialog("_oakhaven.npcs.mayors_party.dog.2")
  end
end

function mayors_friend_1:on_interaction()
  if game:get_value("quest_mayors_dog") < 6 then
    game:start_dialog("_oakhaven.npcs.mayors_party.mayors_friends.1a")
  elseif game:get_value("quest_mayors_dog") < 11 then
    game:start_dialog("_oakhaven.npcs.mayors_party.mayors_friends.1b")
  else
    game:start_dialog("_oakhaven.npcs.mayors_party.mayors_friends.1c")
  end
end

function mayors_friend_2:on_interaction()
  if game:get_value("quest_mayors_dog") < 6 then
    game:start_dialog("_oakhaven.npcs.mayors_party.mayors_friends.2a")
  elseif game:get_value("quest_mayors_dog") < 11 then
    game:start_dialog("_oakhaven.npcs.mayors_party.mayors_friends.2b")
  else
    game:start_dialog("_oakhaven.npcs.mayors_party.mayors_friends.2c")
  end
end

function mayors_friend_3:on_interaction()
  if game:get_value("quest_mayors_dog") < 6 then
    game:start_dialog("_oakhaven.npcs.mayors_party.mayors_friends.3a")
  elseif game:get_value("quest_mayors_dog") < 11 then
    game:start_dialog("_oakhaven.npcs.mayors_party.mayors_friends.3b")
  else
    game:start_dialog("_oakhaven.npcs.mayors_party.mayors_friends.3c")
  end
end
