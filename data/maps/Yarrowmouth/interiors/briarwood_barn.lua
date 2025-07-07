-- Lua script of map Yarrowmouth/interiors/briarwood_barn.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local talked_to_richardo

map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(1)
  sol.menu.start(map, lighting_effects)

  talked_to_richardo = false
  if game:get_value("briarwood_hornet_quest") and game:get_value("briarwood_hornet_quest") >= 1 then
    for hive in map:get_entities("briar_hive") do
      hive:remove()
    end
  end
end)

function richardo:on_interaction()

  if game:get_value("briarwood_hornet_quest") == nil then
    if talked_to_richardo then
      game:start_dialog("_yarrowmouth.npcs.richardo.1-5")
    else
      game:start_dialog("_yarrowmouth.npcs.richardo.1", function()
        local m = sol.movement.create("path")
        m:set_path{4,4,4,4,4,0}
        m:set_speed(70)
        m:set_ignore_obstacles(true)
        m:start(richardo)
        local hx, hy = hero:get_position()
        local rx, ry = richardo:get_position()
        if (math.abs(hy - ry) < 8) and hx < rx then
          hero:set_animation"walking"
          hero:set_direction(3)
          m2 = sol.movement.create"path"
          m2:set_speed(90)
          m2:set_path{6, 6, 6, 2}
          m2:set_ignore_obstacles(true)
          m2:start(hero, function()
            hero:set_direction(1)
            hero:set_animation"stopped"
            hero:unfreeze()
          end)
        end
        talked_to_richardo = true
      end)
    end

  elseif game:get_value("briarwood_hornet_quest") == 1 then
      game:start_dialog("_yarrowmouth.npcs.richardo.2", function()
        game:set_value("briarwood_hornet_quest", 2)
        game:add_money(40)
      end)

  elseif game:get_value("briarwood_hornet_quest") == 2 then
      game:start_dialog("_yarrowmouth.npcs.richardo.3")
  end
end

for hive in map:get_entities("briar_hive") do
  function hive:on_dead()
    if map:has_entities("briar_hive") == false then
      game:set_value("briarwood_hornet_quest", 1)
      sol.audio.play_sound("secret")
    end
  end
end
