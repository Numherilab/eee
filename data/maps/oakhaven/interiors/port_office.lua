-- Lua script of map oakhaven/interiors/port_office.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()


function map:talk_to_benny()
  game:start_dialog("_oakhaven.npcs.port.office.benny1", function(answer)
    if answer == 2 then
      game:start_dialog("_oakhaven.npcs.port.office.benny2")
    end
  end)
end

function benny:on_interaction()
  map:talk_to_benny()
end

function benny_2:on_interaction()
  map:talk_to_benny()
end