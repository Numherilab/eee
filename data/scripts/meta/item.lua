-- Initialize equipment item behavior specific to this quest.

require"scripts/multi_events"

--list of consumables for consumables hud script
local ITEM_LIST = {
  --equipment items
  bow = true, --item
  arrow = "bow", --pickable
  bombs_counter_2 = {}, --item
  bomb = "bombs_counter_2", --pickable
  bow_bombs = true,
  bow_fire = true,
  iron_candle = true, --item
  iron_candle_pickable = "iron_candle", --pickable
  ether_bombs = true, --item
  ether_bombs_pickable = "ether_bombs", --pickable
  homing_eye = true, --item
  homing_eye_pickable = "homing_eye", --pickable
  berries = "berries.1", --use first variant sprite only
  apples = "apples.1",
  bread = "bread.1",
  elixer = true,
  potion_burlyblade = true,
  potion_fleetseed = true,
  potion_magic_restoration = true,
  potion_stoneskin = true,
  
  --collectables
  coral_ore = true,
  burdock = true,
  chamomile = true,
  firethorn_berries = true,
  ghost_orchid = true,
  kingscrown = true,
  lavendar = true,
  witch_hazel = true,
  mandrake_white = true,
  mandrake = true,
  geode = "geode.1",
  monster_bones = "monster_bones.1",
  monster_eye = true,
  monster_guts = "monster_guts.1",
  monster_heart = true,
}

local item_meta = sol.main.get_metatable"item"
item_meta:register_event("on_obtained", function(self, variant)
  local game = self:get_game()
  
  --## trigger quest log update when an item is obtained
  
  local savegame_variable = self:get_savegame_variable()
  if savegame_variable then
    game.objectives:refresh(savegame_variable)
  end

  --## display hud panel for consumables when obtained
  
  local name = self:get_name() --name of the obtained item
  local item_id = ITEM_LIST[name] --name of the item to display
  local variant
  
  --may substitute for different item
  if item_id then
    if type(item_id)=="string" then
      item_id, variant = item_id:match"^([^%.]+)%.?(%d*)$"
      assert(item_id, "ITEM_LIST invalid value for key "..name)
      variant = tonumber(variant) --will be nil of not specified
    else --item_id has value of true
      item_id = name --use itself as the item id
      variant = self:get_variant()
    end
  else return
  end
  
  local item = game:get_item(item_id) --item to be displayed (not necessarily the one obtained)
  assert(item, "Invalid item specified in ITEM_LIST: "..item_id)
  local variant = variant or item:get_variant() --use current variant if not specified
  
  if item:has_amount() and variant>0 then
    local hud = game:get_hud() or {}
    local menu = hud.elements and hud.elements.consumables
    if menu then menu:add_item(item, variant) end --display a panel for the item on the hud
  end
end)


return true
