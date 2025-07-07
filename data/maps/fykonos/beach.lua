local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  if hero:get_position() == from_shipwreck:get_position() and not game:get_value"fykonos_shipwreck_scene" then
    game:get_hud():set_enabled(false)
    hero:freeze()
    hero:get_sprite():set_animation("asleep")
  end
end)

map:register_event("on_opening_transition_finished", function()
  local sprite = hero:get_sprite()
  if not game:get_value"fykonos_shipwreck_scene" then
    hero:freeze()
    sprite:set_animation("asleep")
    game:set_value("fykonos_shipwreck_scene", true)
    sol.timer.start(map, 500, function()
      sprite:set_animation("waking_up", function()
        sprite:set_animation("stopped")
        hero:start_jumping(0, 24, true)
        sol.timer.start(map, 500, function()
          sol.main.get_game():get_hud():set_enabled(true)
          game:set_pause_allowed(true)
          game:start_dialog("_fykonos.observations.shipwreck.no_items", function()
            game:set_value("quest_fykonos", 0)
          end)
          hero:unfreeze()
        end)
      end)
    end)

  end
end)

