local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  if game:get_value("ancient_groves_activated") and game:get_value("ancient_groves_activated") >= 3 then
    glow:set_enabled(true)
    revenant:set_enabled(true)
    if game:get_value"sycamore_revenant_dead" then revenant:set_enabled(false) end
--    boss_sensor:set_enabled(true)
  end
end)

function revenant:on_dead()
  sol.audio.play_sound"secret"
  game:set_value("sycamore_revenant_dead", true)
  map:focus_on(map:get_camera(), rune_door, function()
    map:open_doors"rune_door"
    if game:get_value("quest_ancient_groves") == 1 then game:set_value("quest_ancient_groves", 2) end
    --Unlock achievement
    sol.achievements.unlock("ach_ancient_groves")
  end)
end

function boss_sensor:on_activated()
  hero:freeze()
  hero:set_walking_speed(70)
  hero:walk("222222222222")
  local camera = map:get_camera()
  local m = sol.movement.create"straight"
  m:set_angle(math.pi / 2)
  m:set_speed(70)
  m:set_max_distance(96)
  m:start(camera)
  sol.timer.start(map, 1800, function() sol.audio.play_sound"charge_warp" end)
  sol.timer.start(map, 2000, function()
    map:create_poof(revenant:get_position())
--    revenant:set_enabled(true)
    revenant_dummy:set_enabled(true)
    hero:set_walking_speed(game.normal_walking_speed)
  end)
end
