-- Lua script of map demo_1/boss_cave_antechamber.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local door_manager = require("scripts/maps/door_manager")
door_manager:manage_map(map)
