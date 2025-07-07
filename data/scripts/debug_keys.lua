local debug_keys = {}

function debug_keys:initialize(game)

  local DEBUG_MODE = sol.main.debug_mode
  local ignoring_obstacles

  function game:set_debug_mode(mode) DEBUG_MODE = mode end

  local pause_menu = require"scripts/menus/pause_menu"
  local debug_menu = require"scripts/menus/debug_menu"
  pause_menu.quest_log:set_debug_mode(DEBUG_MODE)

  --Debug Keys
  game:register_event("on_key_pressed", function(self, key, modifiers)
    local hero = game:get_hero()

    if key == "r"  and DEBUG_MODE then
      if hero:get_walking_speed() == 300 then
        hero:set_walking_speed(debug.normal_walking_speed)
      else
        debug.normal_walking_speed = hero:get_walking_speed()
        hero:set_walking_speed(300)
      end

    elseif key == "t" and DEBUG_MODE then
      if not ignoring_obstacles then
        hero:get_movement():set_ignore_obstacles(true)
        ignoring_obstacles = true
      else
        hero:get_movement():set_ignore_obstacles(false)
        ignoring_obstacles = false
      end

    elseif key == "h" and DEBUG_MODE and modifiers.control then
      if modifiers.shift then
        game:set_max_life(game:get_max_life() - 2)
      else
        game:add_max_life(2)
        game:set_life(game:get_max_life())
      end

    elseif key == "h" and DEBUG_MODE then
      if modifiers.shift then
        game:remove_life(2)
      else
        game:set_life(game:get_max_life())
      end

    elseif key == "j" and DEBUG_MODE then
      game:set_magic(game:get_max_magic())

    --Sword, Bow, and Defense
    elseif key == "k" and DEBUG_MODE and modifiers.control then
      sol.audio.play_sound"cursor"
      if modifiers.shift then
        game:set_value("bow_damage", game:get_value("bow_damage") - 1)
      else
        game:set_value("bow_damage", game:get_value("bow_damage") + 1)
      end
      print("Bow Damage: ", game:get_value"bow_damage")

    elseif key == "k" and DEBUG_MODE then
      sol.audio.play_sound"cursor"
      if modifiers.shift then
        game:set_value("sword_damage", game:get_value("sword_damage") - 1)
      else
        game:set_value("sword_damage", game:get_value("sword_damage") + 1)
      end
      print("Sword damage: ", game:get_value"sword_damage")

    elseif key == "l" and DEBUG_MODE then
      sol.audio.play_sound"cursor"
      if modifiers.shift then
        game:set_value("defense", game:get_value("defense") - 1)
      else
        game:set_value("defense", game:get_value("defense") + 1)
      end
      print("Defense: ", game:get_value"defense")
    --------

    elseif key == "l" and DEBUG_MODE then

    elseif key == "m" and DEBUG_MODE then
      print("You are on map: " .. game:get_map():get_id())
      local x, y, l = hero:get_position()
      print("at coordinates: " .. x .. ", " .. y .. ", " .. l)

    elseif key == "y" and DEBUG_MODE then
      --helicopter shot
      if not game.helicopter_cam then
        game:get_map():helicopter_cam()
      else
        game:get_map():exit_helicopter_cam()
        require("scripts/action/hole_drop_landing"):play_landing_animation()
      end

    elseif key == "n" and DEBUG_MODE then
      game:set_value("hard_mode", not game:get_value"hard_mode")
      print("Hard mode: ", game:get_value"hard_mode")

    elseif key == "u" and DEBUG_MODE then
      game:get_hud():set_enabled(not game:get_hud():is_enabled())

    elseif key == "i" and DEBUG_MODE then
      game:set_ability("lift", 1)
      game:set_ability("sword", 1)
      game:get_item("bow"):set_variant(1)
      game:get_item("bow"):add_amount(100)
      game:get_item("bow_warp"):set_variant(1)
      game:get_item("bow_fire"):set_variant(1)
      game:get_item("bow_bombs"):set_variant(1)
      game:get_item("ball_and_chain"):set_variant(1)
      game:get_item("bombs_counter_2"):set_variant(1)
      game:get_item("bombs_counter_2"):add_amount(100)
      game:get_item("boomerang"):set_variant(1)
      game:get_item("spear"):set_variant(1)
      game:get_item("barrier"):set_variant(1)
      game:get_item("crystal_spark"):set_variant(1)
      game:get_item("abyssal_flame"):set_variant(1)
      game:get_item("thunder_charm"):set_variant(1)
      game:get_item("leaf_tornado"):set_variant(1)
      game:get_item("gust"):set_variant(1)

    --[[elseif key == "s" and DEBUG_MODE and modifiers.shift then
      require("scripts/misc/reset_aster_quest"):reset(game)
      print("Aster quest reset")
    --]]
    elseif key == "]" and DEBUG_MODE then
      debug_menu:init(game)
      if sol.menu.is_started(debug_menu) then
        sol.menu.stop(debug_menu)
      else
        sol.menu.start(game, debug_menu)
      end

    end
  end)

end

return debug_keys
