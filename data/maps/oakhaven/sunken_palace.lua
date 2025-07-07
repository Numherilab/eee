-- Lua script of map oakhaven/sunken_palace.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()
local bosses_killed
local secret_switches_pressed

map:register_event("on_started", function()
  map:cloud_overlay("fog/clouds_2.png")
  if game:get_value("sinking_lighthouse_fiend") then fiend_miniboss:remove() end
  map:set_doors_open("boss_door")
  bosses_killed = 0
  secret_switches_pressed = 0
  if game:get_value"sunken_palace_secret_statue_door_opened" then
    secret_door_statue_1:remove()
    secret_door_statue_2:remove()
  end
end)

function entry_bridge_switch:on_activated()
  sol.audio.play_sound"switch"
  map:open_doors"entry_bridge_door"
end

function secondary_door_switch:on_activated()
  map:focus_on(map:get_camera(), secondary_door, function()
    sol.audio.play_sound"switch"
    map:open_doors"secondary_door"
  end)
end

function fiend_miniboss:on_dead()
  game:set_value("sinking_lighthouse_fiend", true)
  map:focus_on(map:get_camera(), miniboss_door, function()
    sol.audio.play_sound"secret"
    map:open_doors"miniboss_door"
  end)
end


function seaglint_ruins_lighthouse_door:on_opened()
  if game:get_value("quest_seaglint_ruins_lighthouse") == 0 then
    game:set_value("quest_seaglint_ruins_lighthouse", 1)
  end
end


function switch_1:on_activated()
  if not game:get_value"oakhaven_sunken_palace_doors_a_state" then
    hero:freeze()
    sol.audio.play_sound("switch_2")
    local camera = map:get_camera()
    local m = sol.movement.create("target")
    m:set_target(camera:get_position_to_track(posts_a_1))
    m:set_ignore_obstacles()
    m:start(camera, function()
      map:open_doors("posts_a")
      sol.timer.start(map, 500, function()
        m:set_target(camera:get_position_to_track(hero))
        m:start(camera, function() hero:unfreeze() camera:start_tracking(hero) end)
      end)
    end)
  end
end

function boss_battle_sensor:on_activated()
  if not game:get_value("sunken_palace_bosses_defeated") then
    map:close_doors("boss_door")
    for boss in map:get_entities("trial_enemy") do
      local x, y, layer = boss:get_position()
      local effect = map:create_custom_entity{
        width = 16, height = 16,
        direction = 0, x = x, y = y, layer = layer, model = "ephemeral_effect", sprite = "entities/poof"
      }
      boss:set_enabled(true)
    end
    boss_battle_sensor:set_enabled(false)
  end
end

for boss in map:get_entities("trial_enemy") do
function boss:on_dead()
  bosses_killed = bosses_killed + 1
  if bosses_killed >= 3 then
    sol.audio.play_sound("secret")
    map:open_doors("boss_door")
    map:create_pickable{
      x = 824, y = 824, layer = 0, treasure_name = "health_upgrade"
    }
    game:set_value("sunken_palace_bosses_defeated", true)
  end
end
end

--secret crow door switches
for switch in map:get_entities"secret_door_switch" do
function switch:on_activated()
  sol.audio.play_sound"switch_2"
  secret_switches_pressed = secret_switches_pressed + 1
  if secret_switches_pressed == 3 then
    map:focus_on(map:get_camera(), secret_door_statue_1, function()
      local x,y,z = secret_door_statue_1:get_position()
      map:create_poof(x + 16, y + 12, z)
      sol.audio.play_sound"switch_2"
      secret_door_statue_1:remove()
      secret_door_statue_2:remove()
      game:set_value("sunken_palace_secret_statue_door_opened", true)
    end)
  end
end
end
