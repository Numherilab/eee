local destructible_meta = sol.main.get_metatable("destructible")

function destructible_meta:on_created()
  self:set_drawn_in_y_order(true)
  if self.set_cut_method ~= nil then  -- Just to be super safe in case the engine is < 1.6.5
    self:set_cut_method("pixel")
  end
  --as of Solarus 1.6, this code is ignored as destructibles are locked to 16x16:
  if self:get_name() == "philodendron_bush" then
    self:set_size(32,16)
  end
end

local foraging_treasures = {
  "arrow",
  "ghost_orchid",
  "firethorn_berries",
  "arrow",
  "apples",
  "kingscrown",
  "burdock",
  "chamomile",
  "berries",
  "lavendar",
  "witch_hazel"
}

destructible_meta:register_event("on_cut", function(self)
  local bush = self
  require("scripts/maps/foraging_manager"):process_cut_bush(bush)
  local sprite_name = bush:get_sprite():get_animation_set()
  if string.match(sprite_name, "bush") then
    sol.audio.play_sound("bush")
  end
  if string.match(sprite_name, "vase") then
    sol.audio.play_sound("breaking_vase")
  end
end)

destructible_meta:register_event("on_lifting", function(self)
  local bush = self
  require("scripts/maps/foraging_manager"):process_cut_bush(bush)
end)

destructible_meta:register_event("on_looked", function(self)
  local game = self:get_game()
  if self:get_weight() > 0 and self:get_weight() > game:get_ability('lift')   then
    game:start_dialog("_game.too_heavy")
  end

end)
