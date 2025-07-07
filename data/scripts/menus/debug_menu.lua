local possible_items = {
  "debug_menu/run",
  "debug_menu/fly",
  "debug_menu/heal",
  "debug_menu/hurt",
  "debug_menu/max_hearts_up",
  "debug_menu/max_hearts_down",
  "debug_menu/sword_up",
  "debug_menu/sword_down",
  "debug_menu/bow_up",
  "debug_menu/bow_down",
  "debug_menu/armor_up",
  "debug_menu/armor_down",
  "debug_menu/magic",
  "debug_menu/fast_travel",
  "debug_menu/hard_mode",
  "debug_menu/hud",
  "debug_menu/all_items",
  "debug_menu/debug_room",
}

local menu = require("scripts/menus/lib/bottomless_list"):build{
  all_items = possible_items,
  num_columns = 6,
  num_rows = 6,
  menu_x = 16
}

function menu:init(game)
    for _, v in ipairs(possible_items) do game:get_item(v):set_variant(1) end
end

menu:register_event("on_command_pressed", function(self, cmd)
  local game = sol.main.get_game()
  if cmd == "action" then
    local item = menu:get_current_item()
    sol.audio.play_sound"cursor"
    item:on_using()

  elseif cmd == "attack" then
    sol.menu.stop(menu)
  end
end)

menu:register_event("on_started", function()
  sol.main.get_game():set_suspended(true)
end)

menu:register_event("on_finished", function()
  sol.main.get_game():set_suspended(false)
end)


return menu