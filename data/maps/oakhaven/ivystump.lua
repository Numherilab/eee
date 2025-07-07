-- Lua script of map oakhaven/ivystump.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  require("scripts/fx/sound_atmosphere_manager"):start_atmosphere(map, "birds")

  --ivy orchard quest
  if game:get_value("quest_ivy_orchard") and game:get_value("quest_ivy_orchard") == 0 then
    for boss in map:get_entities("apple_boss") do boss:set_enabled(true) end
  end

  if game:get_value("quest_ivy_orchard") and game:get_value("quest_ivy_orchard") >= 1 then
    hole_hider:set_enabled(false)
    picker_paul:set_enabled(false)
    for boss in map:get_entities("apple_boss") do boss:set_enabled(false) end
  end

end)


function apple_sample:on_interaction()
  if not game:get_value"ivystump_sampple" then
    game:start_dialog("_oakhaven.npcs.ivystump.misc.apple_sample_1", function()
--      game:get_item("apples"):add_amount(1)
      hero:start_treasure("apples")
      game:set_value("ivystump_sampple", true)
    end)
  else
    game:start_dialog"_oakhaven.npcs.ivystump.misc.apple_sample_2"
  end
end



--quest numbers: 0 = clear orchard, 1 = return to paul, 2 = save paul, 3 = done
function picker_paul:on_interaction()
  if not game:get_value("quest_ivy_orchard") then
    game:start_dialog("_oakhaven.npcs.ivystump.picker_paul.1", function(answer)
      if answer == 3 then
        game:start_dialog("_oakhaven.npcs.ivystump.picker_paul.2", function()
          game:set_value("quest_ivy_orchard", 0)
          for crab in map:get_entities("apple_boss") do crab:set_enabled() end
        end)
      end
    end)

  elseif game:get_value("quest_ivy_orchard") == 0 then
    game:start_dialog("_oakhaven.npcs.ivystump.picker_paul.3")

  elseif game:get_value("quest_ivy_orchard") == 1 then

  end

end


function picker_peter:on_interaction()
  if not game:get_value("quest_ivy_orchard") or game:get_value("quest_ivy_orchard") == 0 then
    game:start_dialog("_oakhaven.npcs.ivystump.picker_peter.1")
  elseif game:get_value("quest_ivy_orchard") == 1 then
    game:start_dialog("_oakhaven.npcs.ivystump.picker_peter.2")
  elseif game:get_value("quest_ivy_orchard") == 2 then
    game:start_dialog("_oakhaven.npcs.ivystump.picker_peter.2")
  elseif game:get_value("quest_ivy_orchard") >= 3 then
    game:start_dialog("_oakhaven.npcs.ivystump.picker_peter.3")
  end
end


for boss in map:get_entities("apple_boss") do
function boss:on_dead()
  if not map:has_entities("apple_boss") then
    sol.audio.play_sound("secret")
    game:set_value("quest_ivy_orchard", 1)
    hole_hider:set_enabled(false)
    picker_paul:set_enabled(false)
  end
end
end


function paul_is_gone_sensor:on_activated()
  if game:get_value("quest_ivy_orchard") == 1 then
    game:start_dialog("_oakhaven.npcs.ivystump.picker_peter.2", function()
      game:set_value("quest_ivy_orchard", 2)
    end)
  end
end
