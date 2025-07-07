-- Lua script of map goatshead_island/interiors/brute_hq.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
--initialize NPCs
--entry guard
  if game:get_value("barbell_brutes_defeated") == true then entry_guard:set_enabled(false) else entry_guard_2:set_enabled(false) end

  if game:get_value("barbell_brutes_defeated") == true then map:close_doors("brute_door") end
  if game:get_value("barbell_boss_bested") == true then barbell_boss:set_enabled(false) end

end)


--entry guard
function entry_guard:on_interaction()
  --have you already talked to this guy and gotten in?
  if game:get_value("barbell_guard_lets_you_in") ~= true then
    --see if you're sent here by Aster
    if game:get_value("accepted_barbell_brute_quest") ~= true then
      --haven't talked to aster about this yet
      game:start_dialog("_goatshead.npcs.guards.barrack_guard.1")
    else
      --on the aster quest line
      game:start_dialog("_goatshead.npcs.guards.barrack_guard.2", function() map:open_doors("brute_door") end)

    end
  else
    --you've already gotten the door open
    game:start_dialog("_goatshead.npcs.guards.barrack_guard.3")
  end
end



--guard captain
function guard_captain:on_interaction()
  if game:get_value("barbell_brutes_defeated") ~= true then
    for entity in map:get_entities("guard_enemy") do entity:set_enabled(false) end
    game:start_dialog("_goatshead.npcs.guards.barrack_guard.5", function()
      game:set_value("barbell_brutes_defeated", true)
      game:set_value("quest_phantom_squid_contracts", 4) --quest log
      entry_guard:set_enabled(false)
    end)
  else
    game:start_dialog("_goatshead.npcs.guards.barrack_guard.6")
  end
end

function barbell_boss:on_dead()
  map:open_doors("boss_door")
  game:set_value("barbell_boss_bested", true)
end
