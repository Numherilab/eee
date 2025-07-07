-- Lua script of map Limestone Island/limestone_village/basswood_tavern.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

--Edson
function edson:on_interaction()
  if game:get_value("basswood_tavern_locked_door") ~= nil then
    if game:get_value("edson_talking_to") ~= true then
      game:start_dialog("_limestone_island.npcs.edson.2")
      game:set_value("edson_talking_to", true)
    else
      game:start_dialog("_limestone_island.npcs.edson.3")
    end
  else
    game:start_dialog("_limestone_island.npcs.edson.1")
  end
end


--Linden
function linden:on_interaction()
  local linden_dialog = game:get_value("linden_intro_dialog")
  if linden_dialog == nil then
    game:start_dialog("_limestone_island.npcs.linden.1")
    game:set_value("linden_intro_dialog", true)
  end

  if linden_dialog == true then
    if game:get_value("basswood_tavern_locked_door") ~= nil then
      game:start_dialog("_limestone_island.npcs.linden.stockroom_open")
    else
      game:start_dialog("_limestone_island.npcs.linden.2")
    end
  end
end
--Linden mandatory talk
function talk_to_linden_sensor:on_activated()
local linden_counter = game:get_value("linden_dialog_counter")
if linden_counter == 0 then
  local see_linden_movement = sol.movement.create("target")
  hero:freeze()
  see_linden_movement:set_target(232, 104)
  hero:set_direction(1)
  hero:set_animation("walking")
  see_linden_movement:start(hero, function()
    game:start_dialog("_limestone_island.npcs.linden.1")
    game:set_value("linden_intro_dialog", true)
    hero:unfreeze()
    game:set_value("linden_dialog_counter", linden_counter + 1)
  end)
end
end
