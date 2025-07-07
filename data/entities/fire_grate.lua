local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local hero = map:get_hero()
local WINDUP_TIME = 400
local turned_off = false

-- Event called when the custom entity is initialized.
function entity:on_created()
  local frequency = entity:get_property("frequency") or 4000

  sol.timer.start(entity, entity:get_property("delay") or 1, function()
    if not turned_off and entity:is_on_screen() then
      entity:shoot_fire()
    end
    return frequency
  end)
end

function entity:shoot_fire()
  local sprite = entity:get_sprite()
  sprite:set_animation("glowing", "off")
  if entity:is_on_screen() and not map.playing_grate_steam_sound then
    sol.audio.play_sound("steam_01")
    map.playing_grate_steam_sound = true
    sol.timer.start(map, 100, function() map.playing_grate_steam_sound = false end)
  end
  sol.timer.start(entity, WINDUP_TIME, function()
    if entity:is_on_screen() and not map.playing_fireburst_sound then
      sol.audio.play_sound("fire_burst_2")
      map.playing_fireburst_sound = true
      sol.timer.start(map, 100, function() map.playing_fireburst_sound = false end)
    end
    local x, y, layer = entity:get_position()
    local fire_blast = map:create_enemy({
      x = x, y = y, layer = layer, direction = 0, breed = "misc/fire_blast"
    })
    sol.timer.start(entity, 400, function()
--      local extra_fire_sprite = fire_blast:create_sprite("entities/fire")
  --    whichsprite = {"a", "b"}
    --  extra_fire_sprite:set_animation("fire_" .. whichsprite[math.random(1,2)])
    end)
  end)
end

function entity:set_turned_off(state)
  turned_off = state
end

function entity:is_on_screen()
  local map = entity:get_map()
  local camera = map:get_camera()
  local camx, camy = camera:get_position()
  local camwi, camhi = camera:get_size()
  local enemyx, enemyy = entity:get_position()

  local on_screen = enemyx >= camx and enemyx <= (camx + camwi) and enemyy >= camy and enemyy <= (camy + camhi)
  return on_screen
end