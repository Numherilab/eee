local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  if game:get_value"quest_bomb_arrows" >= 4 then
    for enemy in map:get_entities_by_type"enemy" do
      enemy:set_enabled(false)
    end
  else
    sol.audio.play_music"boss_battle"
  end
end)

for enemy in map:get_entities("bomb_pirate") do
  function enemy:on_dead()
    if not map:has_entities("bomb_pirate") then
      map:fade_in_music()
      map:focus_on(map:get_camera(), door, function()
        map:open_doors("door")
      end)
    end
  end
end
