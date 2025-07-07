local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(2)
  sol.menu.start(map, lighting_effects)
end)

function door_switch:on_activated()
  map:open_doors"door"
end

function door_switch:on_inactivated()
  map:close_doors"door"
end

function opendoor_sensor:on_activated()
  map:open_doors"door"
end

for enemy in map:get_entities"boss_enemy" do
function enemy:on_dead()
  sol.timer.start(map, 299, function()
    if not map:has_entities("boss_enemy") then
      map:fade_in_music()
      sol.audio.play_sound"secret"
      map:open_doors"boss_door"
    end
  end)
end
end

function boss_music_sensor:on_activated()
  boss_music_sensor:remove()
  sol.audio.play_music"boss_battle"
end


