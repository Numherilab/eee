local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  if game:get_value("visited_hazel_room") == true then
    for entity in map:get_entities("block_book") do entity:set_enabled(false) end
  end

  if game:get_value("quest_manna_oaks") and game:get_value("quest_manna_oaks") >= 1 then hazel:set_enabled(true) end
end)

function festus:on_interaction()
  if game:get_value("lib_festus_counter") == nil then
    if game:get_value("visited_hazel_room") ~= true then
      game:start_dialog("_oakhaven.npcs.library.festus.1")
    else
      game:start_dialog("_oakhaven.npcs.library.festus.2")
      game:set_value("lib_festus_counter", 1)
    end
  elseif game:get_value("lib_festus_counter") == 1 then
    game:start_dialog("_oakhaven.npcs.library.festus.3")
  end
end

function rise_of_the_sea_king:on_interaction()
  game:start_dialog("_oakhaven.observations.hazel_books.5", function(answer)
    if answer == 3 then game:start_dialog("_oakhaven.observations.hazel_books.6") end
  end)
end

function note:on_interaction()
  if game:get_value("find_burglars") ~= true then
    game:start_dialog("_oakhaven.observations.hazel_books.8-note", function()
      game:set_value("quest_hazel", 4)

      game:set_value("quest_log_a", "a12")
      game:set_value("find_burglars", true)
    end)
  end
end


function hazel:on_interaction()
  if game:get_value("quest_manna_oaks") == 1 then
    game:start_dialog("_oakhaven.npcs.hazel.library.1", function()
      pollutant_battle_wall:set_enabled(true)
      pollutant_enemy:set_enabled(true)
      game:set_value("possession_manna_oak_twig", nil)
      game:set_value("possession_manna_oak_letter", 1)
      game:set_value("quest_manna_oaks", 2)
    end)
  elseif game:get_value("quest_manna_oaks") == 2 and not pollutant_enemy:is_enabled() then
    game:start_dialog("_oakhaven.npcs.hazel.library.1", function()
      pollutant_battle_wall:set_enabled(true)
      pollutant_enemy:set_enabled(true)
    end)
  elseif game:get_value("quest_manna_oaks") == 3 then
    game:start_dialog("_oakhaven.npcs.hazel.library.3")
  end
end

function pollutant_enemy:on_dead()
  pollutant_battle_wall:set_enabled(false)
  game:start_dialog("_oakhaven.npcs.hazel.library.2", function()
    game:set_value("quest_manna_oaks", 3)
  end)
end
