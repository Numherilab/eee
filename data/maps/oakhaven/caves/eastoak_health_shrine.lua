-- Lua script of map oakhaven/caves/eastoak_health_shrine.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()


map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(4)
  sol.menu.start(map, lighting_effects)
end)



for enemy in map:get_entities("enemy_a") do
  function enemy:on_dead()
    if not map:has_entities("enemy_a") then
      map:open_doors("door_a")
    end
  end
end

for enemy in map:get_entities("enemy_b") do
  function enemy:on_dead()
    if not map:has_entities("enemy_b") then
      map:open_doors("door_b")
    end
  end
end

for enemy in map:get_entities("enemy_c") do
  function enemy:on_dead()
    if not map:has_entities("enemy_c") then
      map:open_doors("door_c")
    end
  end
end

for enemy in map:get_entities("enemy_d") do
  function enemy:on_dead()
    if not map:has_entities("enemy_d") then
      map:open_doors("door_d")
    end
  end
end

for enemy in map:get_entities("enemy_e") do
  function enemy:on_dead()
    if not map:has_entities("enemy_e") then
      map:open_doors("door_e")
    end
  end
end
