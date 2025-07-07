local map = ...
local game = map:get_game()


map:register_event("on_started", function()
  map:cloud_overlay()
  if game:get_value("quest_bomb_shop") ~= nil and game:get_value("quest_bomb_shop") > 1 then
    bomb_shop_intern:set_enabled(false)
  end

  --put Hazel Ally on the map
  if game:get_value("hazel_is_currently_following_you") and game:get_value("spoken_to_hazel_south_gate") then
    require("scripts/action/hazel_ally"):summon(hero)
  end

end)



function bomb_shop_intern:on_interaction()
  local quest_value = game:get_value("quest_bomb_shop")
  if quest_value == nil then
    game:start_dialog("_oakhaven.npcs.bomb_shop.intern.1", function() game:set_value("quest_bomb_shop", 0) end)

  elseif quest_value  == 0 then
    game:start_dialog("_oakhaven.npcs.bomb_shop.intern.1")

  elseif quest_value == 1 then
    game:start_dialog("_oakhaven.npcs.bomb_shop.intern.2", function()
      hero:freeze()
      game:set_value("quest_bomb_shop", 2)
      local m = sol.movement.create("path")
      m:set_path{0,0,6,6,6,6}
      m:set_ignore_obstacles()
      m:start(bomb_shop_intern, function() hero:unfreeze() end)
    end)

  elseif quest_value == 2 then
    game:start_dialog("_oakhaven.npcs.bomb_shop.intern.2")

  end
end
