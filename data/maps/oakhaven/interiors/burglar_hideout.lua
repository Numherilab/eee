local map = ...
local game = map:get_game()

map:register_event("on_started", function()
    burglar_3:set_enabled(false)
    burglar_4:set_enabled(false)
  if game:get_value("burglars_saved") == true then
    for enemy in map:get_entities("pirate") do enemy:set_enabled(false) end
    burglar_1:set_enabled(false)
    burglar_2:set_enabled(false)
    burglar_3:set_enabled(true)
    burglar_4:set_enabled(true)
  end
end)

function sensor:on_activated()
  if game:get_value("oak_burglars_introduction_to_danger") ~= true then
    game:start_dialog("_oakhaven.npcs.port.burglars.1")
    game:set_value("oak_burglars_introduction_to_danger", true)
  end
end

function burglar_1:on_interaction()
  if game:get_value("burglars_saved") == true then
    game:start_dialog("_oakhaven.npcs.port.burglars.3")
  else
    game:start_dialog("_oakhaven.npcs.port.burglars.yikes")
  end
end

function burglar_2:on_interaction()
  if game:get_value("burglars_saved") == true then
    game:start_dialog("_oakhaven.npcs.port.burglars.2")
  else
    game:start_dialog("_oakhaven.npcs.port.burglars.yikes")
  end
end

function lookout:on_interaction()
  if game:get_value("burglars_saved") ~= true then
    game:start_dialog("_oakhaven.npcs.port.burglars.yikes")
  else
    if game:get_value("oakhaven_palace_secret_passage_knowledge") ~= true then
      game:start_dialog("_oakhaven.npcs.port.burglars.4", function()
        game:set_value("oakhaven_palace_secret_passage_knowledge", true)
        game:set_value("quest_log_a", "a13")
        game:set_value("quest_hazel", 5) --quest log

      end)
    else
      game:start_dialog("_oakhaven.npcs.port.burglars.5")
    end
  end
end


for enemy in map:get_entities("pirate") do
  enemy.on_dead = function()
    if not map:has_entities("pirate") then
      game:set_value("burglars_saved", true)
    end
  end
end
