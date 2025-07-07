--Special Demo-Only Version of Goatshead, most things closed off

local map = ...
local game = map:get_game()

map:register_event("on_opening_transition_finished", function()
  if not game:get_value"fykonos_have_ticket" then
    hero:freeze()
  end
end)

map:register_event("on_started", function()

  if not game:get_value"fykonos_have_ticket" then
    game:get_hud():set_enabled(false)
    map:opening_pan()
  end


--movements
  local apples_walk = sol.movement.create("path")
  apples_walk:set_path{4,6,6,6,6,6,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,6,6,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,2,2,2,2,2,0}
  apples_walk:set_speed(20)
  apples_walk:set_loop(true)
  apples_walk:set_ignore_obstacles(true)
  apples_walk:start(apples_and_oranges_girl)

  local random_walk2 = sol.movement.create("random_path")
  random_walk2:set_speed(10)
  random_walk2:set_ignore_obstacles(false)
  random_walk2:start(market_wanderer)

  local random_walk = sol.movement.create("random_path")
  random_walk:set_speed(10)
  random_walk:set_ignore_obstacles(false)
  random_walk:start(goat_1)

  --dock workers
  local horiz_walk = sol.movement.create("path")
  horiz_walk:set_path{0,0,0,0,0,0,0,0,0,0,0,0,4,4,4,4,4,4,4,4,4,4,4,4}
  horiz_walk:set_speed(20)
  horiz_walk:set_loop()
  horiz_walk:set_ignore_obstacles()
  horiz_walk:start(dockworker_1)

  local horiz_walk2 = sol.movement.create("path")
  horiz_walk2:set_path{0,0,0,0,0,0,0,0,0,0,0,0,4,4,4,4,4,4,4,4,4,4,4,4}
  horiz_walk2:set_speed(20)
  horiz_walk2:set_loop()
  horiz_walk2:set_ignore_obstacles()
  horiz_walk2:start(dockworker_3)

end)


function map:opening_pan()
  local title_card = require"scripts/menus/title_card"
  sol.menu.start(map, title_card)
  --fade title card out after a little
  sol.timer.start(map, 8000, function()
    title_card:fade_out()
  end)

  map:get_camera():start_tracking(camera_guide)
  local angle = camera_guide:get_angle(hero)
  local distance = camera_guide:get_distance(hero)
  local m = sol.movement.create"straight"
  m:set_max_distance(distance)
  m:set_angle(angle)
  m:set_speed(100)
  m:start(camera_guide, function()
    map:get_camera():start_tracking(hero)
    map:fykonos_ticket_dropoff()
  end)

end


function map:fykonos_ticket_dropoff()
  hero:freeze()
  messenger:set_enabled(true)
  local m = sol.movement.create"path"
  m:set_path{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2}
  m:set_speed(100)
  m:start(messenger, function()
    game:start_dialog("_fykonos.npcs.goatshead_messenger.1", function()
      hero:start_treasure("fykonos_ticket", 1, nil, function()
        hero:freeze()
        game:start_dialog("_fykonos.npcs.goatshead_messenger.2", function()
          m:set_ignore_obstacles(true)
          m:set_path{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,0,0,0,0,0,0,2,6}
          m:start(messenger, function()
            game:get_hud():set_enabled(true)
            hero:unfreeze()
            game:set_value("fykonos_have_ticket", true) --savegame for not doing this all again
              game:get_dialog_box():set_style("empty")
              game:start_dialog("_game.controls.action", function()
                game:start_dialog("_fykonos.observations.tutorial.walk", function()
                  game:get_dialog_box():set_style("box")
                end)
              end)
          end)
        end)
      end)
    end)
  end)
end

function max:on_interaction()
  game:start_dialog("_fykonos.npcs.max.1", function()
    hero:teleport("fykonos/intro/ship_below_deck", "arrival_destination")
  end)
end



--town guards
function guard_1:on_interaction()
  if game:get_value("barbell_brutes_defeated") ~= true then
    game:start_dialog("_goatshead.npcs.guards.1")
  else
    game:start_dialog("_goatshead.npcs.guards.post_defeat.2")
  end
end

function guard_2:on_interaction()
  if game:get_value("barbell_brutes_defeated") ~= true then
    game:start_dialog("_goatshead.npcs.guards.2")
  else
    game:start_dialog("_goatshead.npcs.guards.post_defeat.3")
  end
end

function guard_3:on_interaction()
  if game:get_value("barbell_brutes_defeated") ~= true then
    game:start_dialog("_goatshead.npcs.guards.3")
  else
    game:start_dialog("_goatshead.npcs.guards.post_defeat.1")
  end
end

function guard_4:on_interaction()
  if game:get_value("barbell_brutes_defeated") ~= true then
    game:start_dialog("_goatshead.npcs.guards.4")
  else
    game:start_dialog("_goatshead.npcs.guards.post_defeat.1")
  end
end

function guard_5:on_interaction()
  if game:get_value("barbell_brutes_defeated") ~= true then
    game:start_dialog("_goatshead.npcs.guards.8")
  else
    game:start_dialog("_goatshead.npcs.guards.post_defeat.1")
  end
end

