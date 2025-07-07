local map = ...
local game = map:get_game()
local started_battle
local won_battle

map:register_event("on_started", function()
  started_battle = false
  won_battle = false
  --already defeated monsters
  if game:get_value("oakhaven_sculptor_battle") then
    for e in map:get_entities_by_type"enemy" do
      e:remove()
    end
  end
end)

function sculptor:on_interaction()
  if game:get_value("oakhaven_sculptor_battle") then
    game:start_dialog"_oakhaven.npcs.sculptor.4"

  elseif won_battle == true then
    game:start_dialog("_oakhaven.npcs.sculptor.3", function()
      game:set_value("oakhaven_sculptor_battle", true)
      map:get_hero():start_treasure("geode", 4)
    end)

  elseif started_battle == true then
    game:start_dialog"_oakhaven.npcs.sculptor.2"

  else
    game:start_dialog("_oakhaven.npcs.sculptor.1", function(answer)
      game:start_dialog("_oakhaven.npcs.sculptor.2", function()
        sol.audio.play_sound"door_unlocked"
        for door in map:get_entities"cage_door" do door:set_enabled(false) end
        started_battle = true
      end)
    end)

  end
end

for enemy in map:get_entities"gravel_guy" do
function enemy:on_dead()
  if not map:has_entities"gravel_guy" then
    won_battle = true
    started_battle = false
  end
end
end

sol.timer.start(map, 100, function()
  if started_battle and not map:has_entities"gravel_guy" then
    won_battle = true
    started_battle = false
  end
end)
