require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_started", function(self)
  item:set_savegame_variable("possession_potion_fleetseed")
  item:set_amount_savegame_variable("amount_potion_fleetseed")
  item:set_max_amount(99)
  item:set_assignable(false)
end)

item:register_event("on_obtaining", function(self)
  self:add_amount(1)
end)

item:register_event("on_using", function(self)
  if self:get_amount() > 0 then
    --If status is already active
    if game.fleetseed_active then
      sol.audio.play_sound"no"
      return
    end
    self:remove_amount(1)
    item:drink()
  end
  item:set_finished()
end)


function item:drink()
    sol.audio.play_sound("uncorking_and_drinking_1")
    game:get_hero():set_walking_speed(150)
    game.fleetseed_active = true
    game:start_dialog"_game.potion.fleetseed"
    local status_menu = require"scripts/hud/status_effect"
    if not sol.menu.is_started(status_menu) then sol.menu.start(game, status_menu) end
    status_menu.speed_surface:fade_in()
    sol.timer.start(game, 30000, function() --240000 is 4 minutes, 300000 is 5
      game:get_hero():set_walking_speed(98)
      game.fleetseed_active = false
      status_menu.speed_surface:fade_out()
      sol.audio.play_sound"status_deactivated"
--      require("scripts/hud/message"):show_message("Potion effect expired", 2800)
    end)
end
