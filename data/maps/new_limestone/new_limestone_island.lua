local map = ...
local game = map:get_game()
local hero = game:get_hero()

map:register_event("on_started", function()
  --for intro cutscene
  if not game:get_value("scrolling_limestone_intro_cutscene") then
    map:get_hero():set_visible(false)
    sol.main.get_game():get_hud():set_enabled(false)
    game:set_pause_allowed(false)
  end
end)

function hazel:on_interaction()
  if not game:has_ability("sword") then
    game:start_dialog("_new_limestone_island.npcs.hazel.1", function()
      hero:start_treasure("sword", 1, "limestone_hazel_gave_you_sword", function()
        game:start_dialog("_new_limestone_island.npcs.hazel.2")
      end)
    end)
  else
    game:start_dialog("_new_limestone_island.npcs.hazel.3")
  end
end

function see_bush_sensor:on_activated()
  if not game:get_value"new_limestone_seen_blocker_bush" and not game:has_item"sword" then
    game:start_dialog"_new_limestone_island.observations.blocker_bush"
    game:set_value("new_limestone_seen_blocker_bush", true)
  end
end

function controls_sensor:on_activated()
  local pause_key = game:get_command_keyboard_binding("pause")
  if sol.main.get_os() == "Nintendo Switch" then
    pause_key = "(+)"
  else
    pause_key = string.upper(pause_key)
  end
  if not game:get_value("limestone_controls_explanation_pause") then
    game:get_dialog_box():set_style("empty")
    game:start_dialog("_game.controls.pause", pause_key, function()
      game:get_dialog_box():set_style("box")
      game:set_value("limestone_controls_explanation_pause", true)
    end)
  end
end


--=================Intro Cutscene=======================--
map:register_event("on_opening_transition_finished", function()
  if not game:get_value("scrolling_limestone_intro_cutscene") then
    game:set_value("scrolling_limestone_intro_cutscene", true)
    local title_card = require"scripts/menus/title_card"
    sol.main.get_game():get_hud():set_enabled(false)
    sol.menu.start(game, title_card)
    hero:freeze()

    --set up target to track
    local x,y,z = hero:get_position()
    local target = map:create_custom_entity{
      x=x, y=y, layer=z, direction=0, width=16, height=16,
    }
    map:get_camera():start_tracking(target)
    local m = sol.movement.create("target")
    m:set_target(from_tavern)
    m:set_ignore_obstacles()
    m:set_speed(45)
    m:start(target, function()
      map:get_hero():teleport("new_limestone/tavern_upstairs", "destination")
      hero:set_visible(true)
    end)

    --fade title card out after a little
    sol.timer.start(map, 8000, function()
      title_card:fade_out()
    end)

    --start hazel walking
    intro_hazel:set_enabled(true)
    local hm = sol.movement.create"target"
    hm:set_target(intro_hazel_destination)
    hm:set_speed(20)
    sol.timer.start(map, 17 * 1000, function() hm:start(intro_hazel) end)

    --move invisible hero near seagulls to spook them
    sol.timer.start(map, 17 * 1000, function()
      hero:set_position(872, 864)
    end)
  end
end)
