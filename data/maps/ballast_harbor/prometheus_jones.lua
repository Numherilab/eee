-- Lua script of map ballast_harbor/prometheus_jones.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()




function prometheus:on_interaction()
  if game:has_item("ball_and_chain") then
    local flail = game:get_item("ball_and_chain")
    local variant = flail:get_variant()
    if variant == 1 then
      game:start_dialog("_ballast_harbor.npcs.prometheus_jones.2", function(answer)
        if answer == 3 then --make it explode
          flail:set_variant(2)
          sol.audio.play_sound"clank"
          sol.audio.play_sound"heart"
          sol.audio.play_sound"ok"
          sol.audio.play_sound"rupee_counter_end"
          game:start_dialog("_ballast_harbor.npcs.prometheus_jones.make_explode")
        else
          game:start_dialog("_ballast_harbor.npcs.prometheus_jones.dont_do_it")
        end
      end)
    elseif variant == 2 then
      game:start_dialog("_ballast_harbor.npcs.prometheus_jones.downgrade_choice", function(answer)
        if answer == 3 then --change it back
          game:start_dialog("_ballast_harbor.npcs.prometheus_jones.dont_do_it")
          flail:set_variant(1)
          sol.audio.play_sound"clank"
          sol.audio.play_sound"heart"
          sol.audio.play_sound"ok"
          sol.audio.play_sound"rupee_counter_end"
          sol.achievements.unlock("ach_exploding_flail")
        else --nope, keep exploding
          game:start_dialog("_ballast_harbor.npcs.prometheus_jones.stay_exploding")
        end
      end)
    end


  else --you don't have the flail
    game:start_dialog("_ballast_harbor.npcs.prometheus_jones.1")
  end
end
