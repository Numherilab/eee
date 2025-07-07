-- Lua script of map Yarrowmouth/silent_glade.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local switches_on = 0

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  sol.timer.start(map, 100, function()
    if switches_on >= 5 then
      map:open_doors("silent_glade_door")
    end
    return true
  end)
end)



function silent_glade_switch_1:on_activated()
  switches_on = switches_on + 1
end

function silent_glade_switch_1:on_inactivated()
  switches_on = switches_on - 1
end

function silent_glade_switch_2:on_activated()
  switches_on = switches_on + 1
end

function silent_glade_switch_2:on_inactivated()
  switches_on = switches_on - 1
end

function silent_glade_switch_3:on_activated()
  switches_on = switches_on + 1
end

function silent_glade_switch_3:on_inactivated()
  switches_on = switches_on - 1
end

function silent_glade_switch_4:on_activated()
  switches_on = switches_on + 1
end

function silent_glade_switch_4:on_inactivated()
  switches_on = switches_on - 1
end

function silent_glade_switch_5:on_activated()
  switches_on = switches_on + 1
end

function silent_glade_switch_5:on_inactivated()
  switches_on = switches_on - 1
end

