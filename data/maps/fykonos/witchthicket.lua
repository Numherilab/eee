local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  if (game:get_value("fykonos_bombino_counter") or 0) >= 3 then bombino:remove() end  
  if (game:get_value("fykonos_bombino_counter") or 0) >= 2 then backpack:remove() end

  for enemy in map:get_entities_by_type"enemy" do
    if enemy:get_breed() == "normal_enemies/arborgeist_stump" then
      enemy:set_life(25+10) enemy:set_hurt_style"normal"
    end
  end

end)

local bt = backpack:get_treasure()
function bt:on_obtained()
  map:focus_on(map:get_camera(), bombino, function()
    game:start_dialog("_fykonos.npcs.bombino.2")
    game:set_value("fykonos_bombino_counter", 2)
  end)
end

function bombino:on_interaction()
  if not game:get_value"fykonos_bombino_counter" then
    game:start_dialog"_fykonos.npcs.bombino.1"
    game:set_value("fykonos_bombino_counter", 1)

  elseif game:get_value"fykonos_bombino_counter" == 1 then
    game:start_dialog"_fykonos.npcs.bombino.1.2"

  elseif game:get_value"fykonos_bombino_counter" == 2 then
    game:set_value("fykonos_bombino_counter", 3)
    game:set_value("fykonos_bombs_available", true)
    game:start_dialog("_fykonos.npcs.bombino.3", function()
      hero:start_treasure("bomb", 4, nil, function()
        game:start_dialog("_fykonos.npcs.bombino.4", function()
          local m = sol.movement.create"path"
          m:set_path{6,6,6,4,4,4,4,6,6,6,6,6,6,6,6,6,6}
          m:set_speed(80)
          m:set_ignore_obstacles(true)
          m:start(bombino, function()
            m = sol.movement.create"jump"
            m:set_direction8(6)
            m:set_distance(96)
            m:set_speed(100)
            m:set_ignore_obstacles(true)
            m:start(bombino)
            bombino:get_sprite():set_animation"jumping"
            sol.audio.play_sound"jump"
          end)
        end)
      end)
    end)

  end
end
