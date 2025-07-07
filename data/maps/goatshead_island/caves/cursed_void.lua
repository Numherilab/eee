local map = ...
local game = map:get_game()

local white = sol.surface.create()
white:fill_color({255,255,255})

map:register_event("on_started", function()
  game:get_hud():set_enabled(false)
  hero:freeze()
  sol.timer.start(map, 700, function() white:fade_out(150) end)
  sol.timer.start(map, 4800, function()
    game:start_dialog("_goatshead.observations.cursed_god", function(answer)
      hero:freeze()
      if answer == 3 then
        game:set_value("cursed_bell_first_ring", true)
        map:switch_hard_mode_state()
      else
        hero:set_animation"floating"
        sol.timer.start(map, 1000, function()
          game:get_hud():set_enabled(true)
          hero:teleport("goatshead_island/cursed_temple", "from_void")
          map:create_poof(hero:get_position())
          hero:set_animation("asleep")
        end)
      end
    end)
  end)
end)

map:register_event("on_opening_transition_finished", function() hero:freeze() end)



function map:switch_hard_mode_state()
  hero:freeze()
  hero:set_direction(3)
  hero:set_animation"floating"
  local direction
  if not game:get_value"hard_mode" then
    game:set_value("hard_mode", true)
    direction = "in"
    sol.audio.play_sound"charge_2"
  else
    game:set_value("hard_mode", false)
    direction = "out"
    sol.audio.play_sound"charge_3"
  end


  sol.timer.start(map, 1000, function()
    map:sparkle_effect(direction)
  end)
  sol.timer.start(map, 2400, function()
    hero:unfreeze()
    game:get_hud():set_enabled(true)
    hero:teleport("goatshead_island/cursed_temple", "from_void")
    game:start_dialog("_game.hard_mode." .. direction, function()
      game:get_dialog_box():set_style"box"
    end)
  end)
end


function map:sparkle_effect(direction)
  local x, y, z = hero:get_position()
  for i=1, 40 do
    if direction == "in" then
      x = x + math.random(-56, 56)
      y = y + math.random(-56, 56)
    end
    local sparkle = map:create_custom_entity{
      x=x, y=y, layer=z, direction=0, width=8, height=16,
      sprite = "entities/lantern_sparkle",
    }
    sparkle:get_sprite():set_animation("sparkle_" .. math.random(1,2), function()
      sparkle:remove()
    end)
    sparkle:get_sprite():set_ignore_suspend(true)
    sparkle:set_drawn_in_y_order(true)
    local m = sol.movement.create"straight"
    m:set_speed(90)
    m:set_ignore_obstacles(true)
    m:set_ignore_suspend(true)
    if direction == "in" then
      m:set_angle(sparkle:get_angle(hero))
      m:set_max_distance(sparkle:get_distance(hero))
      m:set_speed(sparkle:get_distance(hero) * 2)
      if math.random(1, 3) == 2 then
        sparkle:get_sprite():set_color_modulation{255, 100, 100}
      end
    else
      m:set_angle(math.random(100) * 2 * math.pi / 100)
      m:set_max_distance(math.random(24, 56))
    end
    sol.timer.start(map, math.random(1, 400), function() m:start(sparkle) end)
  end
end

function map:on_draw(dst)
  white:draw(dst)
end
