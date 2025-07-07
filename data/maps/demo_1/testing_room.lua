-- Lua script of map demo_1/testing_room.
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

function test_switch_1:on_activated()
map:open_doors("1")
end

function test_switch_1:on_inactivated()
map:close_doors("1")
end

function vines:on_collision_fire()
map:remove_entities("vines")
end

function chest_switch:on_activated()
map:create_chest({
layer = 0,
x = 48,
y = 96,
sprite = "entities/chest",
})
end