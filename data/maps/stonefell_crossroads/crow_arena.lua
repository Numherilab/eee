local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  require("scripts/fx/sound_atmosphere_manager"):start_atmosphere(map, "ravens")
  require("scripts/fx/sound_atmosphere_manager"):start_atmosphere(map, "rain")
  local world = map:get_world()
  game:set_world_rain_mode(world, "rain")

  if game:get_value("quest_crow_lord") and game:get_value("quest_crow_lord") >= 1 then
    map:set_doors_open"boss_door"
  end
end)

function challenge_sensor:on_activated()
  if game:get_value("quest_crow_lord") == 0 and not crow_lord:is_enabled() then
    game:start_dialog("_sycamore_ferry.other.crow_lord_challenge", function(answer)
      map:focus_on(map:get_camera(), crow_lord, function()
        map:create_poof(crow_lord:get_position())
        crow_lord:set_enabled()
        sol.audio.play_music"boss_battle"
      end)
    end)
  end
end

function crow_lord:on_dead()
  map:fade_in_music()
  map:focus_on(map:get_camera(), boss_door, function()
    map:open_doors"boss_door"
    game:set_value("quest_crow_lord", 1)
  end)
  sol.timer.start(game, 3000, function() sol.achievements.unlock("ach_crow_lord") end)
end