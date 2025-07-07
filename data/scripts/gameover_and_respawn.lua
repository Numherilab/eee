local manager = {}

local map_meta = sol.main.get_metatable("map")

function manager:initialize(game)
  --Initiate respawning when loading a game
  game:register_event("on_started", function()
    if game:get_value"respawn_map" then
      game.respawn_screen = require("scripts/menus/respawn_screen")
      sol.menu.start(game, game.respawn_screen)
      game.respawning = true
    end
  end)



  function game:set_respawn_point()
    --print"Setting respawn point..."
    local map = game:get_map()
    local hero = game:get_hero()
    local loc_ground = hero:get_ground_below()
    local x, y, layer = hero:get_position()
    local map_width, map_height = map:get_size()
    if x > map_width or y > map_height then
      print("OFFSIDES! Map size:", map:get_size(), "Hero position", hero:get_position())
      error("Hero is outside the bounds of the map!")
    end
    if not hero:test_obstacles() and loc_ground ~= "deep_water"
    and x <= map_width and y <= map_height and x >= 0 and y >= 0
    and not (hero:get_state() == "stairs")
    then
      --game:set_starting_location(map:get_id() )
      game:set_value("respawn_map", map:get_id() ) --don't use built-in starting location, will be overwritten by destinations autoupdating it!
      game:set_value("respawn_x", x)
      game:set_value("respawn_y", y)
      game:set_value("respawn_layer", layer)
      game:set_value("respawn_direction", hero:get_direction())
      --print"Respawn point set!"
    end
  end


  --Set Respawn point whenver map changes ----
  map_meta:register_event("on_opening_transition_finished", function()
    local map = game:get_map()
    if game.respawning == true and map:get_id() ~= "respawn_map" then
      game.respawning = false
      map:move_to_respawn_point()

    elseif map:get_id() ~= "respawn_map" then 
      game:set_respawn_point()
    end
  end)


  function map_meta:move_to_closest_open_destination()
    local hero = game:get_hero()
    local map = game:get_map()
    local dist = 1000000000000000000000000000
    local closest_destination
    local hx, hy, hz = hero:get_position()
    for dest in map:get_entities_by_type"destination" do
      local ex, ey, ez = dest:get_position()
      local dx = ex - hx
      local dy = ey - hy
      if not hero:test_obstacles(dx, dy, ez) and hero:get_distance(dest) < dist then
        closest_destination = dest
        dist = hero:get_distance(dest)
      end
    end
    hero:set_position(closest_destination:get_position())
    sol.menu.stop(game.respawn_screen)
  end


  function map_meta:move_to_respawn_point()
      local hero = game:get_hero()
      local map = game:get_map()
      hero:set_position(game:get_value("respawn_x"), game:get_value("respawn_y"), game:get_value("respawn_layer"))
      hero:set_direction(game:get_value("respawn_direction"))
      --Check to see if we've loaded into an obstacle
      if hero:test_obstacles() then
        map:move_to_closest_open_destination()
        print("Error! Loaded into Obstacle, recalibrating starting destination.")
        print("Map", map:get_id(), hero:get_position() )
      elseif hero:get_ground_below() == "hole" or hero:get_ground_below() == "deep_water" then
        map:move_to_closest_open_destination()
        print("Error! Loaded into water or hole, recalibrating starting destination.")
        print("Map", map:get_id(), hero:get_position() )
      else
        sol.menu.stop(game.respawn_screen)
      end
  end


  local function game_over_stuff_part_2()
      --send the hero to the respawn location saved earlier
      local hero = game:get_hero()
      game.respawning = true
      game:set_life(math.max(game:get_max_life() * .8, 6))
      hero:set_invincible(true, 1500)
      hero:teleport("respawn_map")
      game:stop_game_over()
  end

  local function game_over_stuff()
      local elixer = game:get_item("elixer")
      local amount_elixer = elixer:get_amount()
      local hero = game:get_hero()

      if amount_elixer > 0 then
        sol.audio.set_music_volume(game:get_value("music_volume"))
        game:set_life(game:get_value("elixer_restoration_level"))
        hero:set_animation("walking")
        elixer:remove_amount(1)
        game:stop_game_over()
      else
        sol.audio.stop_music()
        sol.audio.set_music_volume(game:get_value("music_volume"))
        game:start_dialog("_game.game_over", function(answer)
          --save and continue
          if answer == 2 then
            game:set_starting_location(game:get_value"respawn_map")
            game:save()
            game_over_stuff_part_2()
          --contine without saving
          elseif answer == 3 then
            game_over_stuff_part_2()
          --quit
          elseif answer == 4 then
            sol.timer.start(sol.main, 20, function() sol.main.reset() end)
          end

        end) --end gameover dialog choice
      end --end "if elixers" condition
  end --end gameover stuff function


  function game:on_game_over_started()
    local hero = game:get_hero()
    sol.audio.set_music_volume(1)
    hero:set_animation("dead")
    sol.audio.play_sound("hero_dying")
    sol.timer.start(game, 1500, game_over_stuff)
  end

end


return manager