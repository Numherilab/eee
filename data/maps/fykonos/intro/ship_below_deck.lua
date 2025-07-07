local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  --already Max came and said there was an attack
  if game:get_value"fykonos_ship_attacked" then
    cabin_door:remove()
    max:remove()

  --If the attack hasn't yet happened
  else
    if not game:get_value"fykonos_not_demo" then
      game:get_dialog_box():set_style("empty")
      game:start_dialog("_fykonos.observations.tutorial.sword", function()
        game:get_dialog_box():set_style("box")
      end)
    end
    --Set up Max coming down stairs
    sol.timer.start(map, 5000, function()
      sol.audio.play_sound"thunk1"
      sol.audio.play_sound"switch_2"
      sol.audio.play_sound"hand_cannon"
      sol.timer.start(map, 500, function()
        sol.audio.play_sound"stairs_down_end"
        sol.timer.start(map, 500, function()
          map:theres_been_an_attack()
        end)
      end)
    end)
  end --end attack hasn't yet happened


  if game:get_value"fykonos_ship_defended" then
    crash_sensor:set_enabled(true)
    tele:set_enabled(false)
    stair:set_enabled(false)
  end

  sol.timer.start(map, 0, function()
    sol.audio.play_sound"ship_creak_lowpass_7s"
    return 7000
  end)

end)


function map:theres_been_an_attack()
  max:set_enabled(true)
  map:open_doors"cabin_door"
  sol.timer.start(map, 400, function()
    game:start_dialog("_fykonos.npcs.max.been_attack", function()
      max:set_enabled(false)
      sol.audio.play_sound"stairs_up_end"
      game:set_value("fykonos_ship_attacked", true)
    end)
  end)
end

local black_screen = sol.surface.create()
function crash_sensor:on_activated()
  crash_sensor:remove()
  sol.audio.play_sound"thunk1"
  sol.audio.play_sound"switch_2"
  sol.audio.play_sound"wood_breaking_and_falling_into_water"
  sol.timer.start(map, 400, function() sol.audio.play_sound"wood_breaking_and_falling_into_water" end)
  sol.timer.start(map, 600, function() sol.audio.play_sound"wood_breaking_and_falling_into_water" end)
  sol.timer.start(map, 900, function() sol.audio.play_sound"wood_breaking_and_falling_into_water" end)
  game:start_dialog("_fykonos.observations.shipwreck.bad_sound", function()
    black_screen:fill_color{0,0,0}
    game:get_hud():set_enabled(false)
    hero:freeze()
    sol.audio.play_sound"hand_cannon"
    if game:get_value"fykonos_not_demo" then
      map:remove_items()
    else
      map:remove_items_demo()
    end
    sol.timer.start(map, 2000, function()
      hero:teleport("fykonos/beach", "from_shipwreck")
    end)
  end)
end

function map:remove_items()
  game:get_item("sword"):set_variant(0)
  game:set_value("fykonos_amount_arrows_stolen", game:get_item("bow"):get_amount())
  game:get_item("bow"):set_variant(0)
  if game:has_item"boomerang" then
    game:set_value("fykonos_boomerang_stolen", true)
    game:set_value("fykonos_boomerang_stolen_variant", game:get_item("boomerang"):get_variant())
    game:get_item("boomerang"):set_variant(0)
  end
  game:get_item("spear"):set_variant(0)
  game:set_value("fykonos_amount_bombs_stolen", game:get_item("bombs_counter_2"):get_amount())
  game:get_item("bombs_counter_2"):set_variant(1)
  game:get_item("bombs_counter_2"):set_amount(0)
  game:get_item("oak_charm"):set_variant(0)
  game:set_ability("lift", 0)
  game:set_item_assigned(1, nil)
  game:set_item_assigned(2, nil)
  require("scripts/menus/inventory"):initialize_assigned_item_sprites(game)
end

function map:remove_items_demo()
  game:get_item("sword"):set_variant(0)
  game:get_item("bow"):set_variant(0)
  game:get_item("boomerang"):set_variant(0)
  game:get_item("barrier"):set_variant(0)
  game:get_item("bombs_counter_2"):set_variant(1)
  game:get_item("bombs_counter_2"):set_amount(0)
  game:set_item_assigned(1, nil)
  game:set_item_assigned(2, nil)
  require("scripts/menus/inventory"):initialize_assigned_item_sprites(game)

end

function map:on_draw()
  map:draw_visual(black_screen, 0, 0)
end

