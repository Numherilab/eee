-- Lua script of map goatshead_island/interiors/sodden_cormorant.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  if not game:get_value("sodden_cormorant_found_quest") then
    game:set_value("quest_meet_juglan_at_pier", 2)      ----quest log
    game:set_value("sodden_cormorant_found_quest", true)
  end
  if game:get_value("goatshead_tunnels_accepted") == true then
    adventurer_1:set_enabled(false)
    adventurer_2:set_enabled(false)
    adventurer_3:set_enabled(false)
  end

end)


--Spruce Head Clue
function thiel:on_interaction()
  game:start_dialog("_generic_dialogs.eh")
end

--Ballast Harbor Clue
function thiesson:on_interaction()
  game:start_dialog("_generic_dialogs.eh")
end

--Leigha
function leigha:on_interaction()
  --first time talking
  if game:get_value("talked_to_leigha") ~= true then
    map:get_hero():freeze()
    game:start_dialog("_goatshead.npcs.tavern_people.leigha.1", function()
      local m1 = sol.movement.create("path")
      m1:set_path{4,4}
      m1:start(thiel)
      function m1:on_finished()
        game:start_dialog("_goatshead.npcs.tavern_people.leigha.3", function()
          game.world_map:set_map_visible("stonefell_crossroads/spruce_head") --make spruce head visible
          local m2 = sol.movement.create("path")
          m2:set_path{0,0}
          m2:start(thiesson)
          function m2:on_finished()
            game:start_dialog("_goatshead.npcs.tavern_people.leigha.4", function()
              map:get_hero():unfreeze()
              game:set_value("quest_kelpton", 0) --quest log
              game:set_value("quest_spruce_head", 0) --quest log
              game.world_map:set_map_visible("stonefell_crossroads/spruce_head")
            end)
          end
        end)
      end
      game:set_value("talked_to_leigha", true)
      game:set_value("have_ballast_harbor_clue", true)
      game:set_value("have_spruce_clue", true)
      game:set_value("quest_log_a", "a4")

      game:set_value("quest_log_b", "b1")
    end)

  --assign quest
  else game:start_dialog("_goatshead.npcs.tavern_people.leigha.2")
  end
end

--Adventurers in the tunnels quest
function adventurer_1:on_interaction()
if game:get_value("goatshead_tunnels_accepted") ~= true then
  game:start_dialog("_goatshead.npcs.tavern_people.adventurers.3", function(answer)
    if answer == 2 then
      game:start_dialog("_goatshead.npcs.tavern_people.adventurers.4", function(answer)
        if answer == 2 then
          game:start_dialog("_goatshead.npcs.tavern_people.adventurers.5", function()
            game:set_value("goatshead_tunnels_accepted", true)
            game:set_value("quest_goatshead_secret_tunnels", 0) --quest log update
          end)
        end
      end)
    end
  end)
else
  game:start_dialog("_goatshead.npcs.tavern_people.adventurers.6")
end
end
