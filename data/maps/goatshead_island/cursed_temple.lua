local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  require("scripts/fx/sound_atmosphere_manager"):start_atmosphere(map, "rain")
  local world = map:get_world()
  game:set_world_rain_mode(world, "rain")


  --Bell
  bell:set_layer_independent_collisions(true)
  bell:add_collision_test("sprite", function(bell, entity, bellsprite, entitysprite)
    if not bell.ringing
    and entitysprite:get_animation_set() == "hero/sword1"
    or entitysprite:get_animation_set() == "hero/spear" then
      sol.audio.play_sound"bell_town"
      bell:get_sprite():set_animation"ringing"
      bell.ringing = true
      sol.timer.start(map, 3800, function()
        bell.ringing = false
        bell:get_sprite():set_animation"stopped"
      end)
    hero:freeze()
    sol.timer.start(map, 500, function()
      if not game:get_value"cursed_bell_first_ring" then
        hero:teleport("goatshead_island/caves/cursed_void")
      else
        map:switch_hard_mode_state()
      end
    end)

    end
  end)

  --Achievement for ringing bell
  if game:get_value"cursed_bell_first_ring" then
    sol.achievements.unlock("ach_cursed_temple")
  end

  --Cursed Marble no-hit challenge
  if game.cursed_marble_no_hit_check then sol.achievements.unlock("ach_no_hit_path") end

end)


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
    game:get_dialog_box():set_style"empty"
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


--Curse Stones:

local hard_effect_variables = {
  "hard_mode_enemy_life",
  "hard_mode_enemy_damage",
  "hard_mode_healing_items",
  "hard_mode_iframes",
}

for i=1, 4 do
  local entity = map:get_entity("curse_stone_" .. i)
  function entity:on_interaction()
    game:start_dialog("_game.hard_mode." .. i, function(answer)
      local flame = map:get_entity("curse_flame_" .. i)
      if answer == 3 then
        flame:set_enabled(true)
        game:set_value(hard_effect_variables[i], true)
      elseif answer == 4 then
        flame:set_enabled(false)
        game:set_value(hard_effect_variables[i], false)
      end
    end)
  end

end

