-- Lua script of map debug_room.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  local hero = game:get_hero()
--  hero:set_walking_speed(96)
end)

-----------------___TEMP---------------
function subtest:on_interaction()
  game:start_dialog("_test.sub", "MAX")
end

---------------------------------------


function shopkeeper:on_interaction()
  local shop_menu = require("scripts/shops/shop_menu")
  shop_menu:initialize(game)
  sol.menu.start(map, shop_menu)
end

function buyer:on_interaction()
  local shop_menu = require("scripts/shops/sell_menu")
  shop_menu:initialize(game)
  sol.menu.start(map, shop_menu)
end

function blacksmith:on_interaction()
  local shop_menu = require("scripts/shops/blacksmith")
  shop_menu:open_shop(game)
end

function camera_shaker:on_interaction()
  map:get_camera():shake({count = 6, amplitude = 4, speed = 80})
end

function max:on_interaction()
  game:start_dialog("_generic_dialogs.max.beta_test_greeting", function()
    map:get_hero():teleport("new_limestone/new_limestone_island", "intro_cutscene")
  end)
end