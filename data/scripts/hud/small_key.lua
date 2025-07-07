local small_key_menu = {}

local key_sprite = sol.sprite.create("hud/small_key_icon")
local key_surface = sol.surface.create()

--[[ local map_key_map = {
  "Yarrowmouth/bear_catacombs/bear_catacombs" = "key_bear_catacombs",
  "oakhaven/fort_crow/fort_crow" = "key_fort_crow",
  "goatshead_island/caves/goat_caverns" = "key_goat_caverns",
  "goatshead_island/interiors/tunnels" = "key_goat_tunnels",
  "snapmast_reef/cemetery_of_the_waves/shipwreck_chain" = "key_graveyard_of_the_waves",
  "snapmast_reef/cemetery_of_the_waves/blackbeard_cabin" = "key_graveyard_of_the_waves",
  "Yarrowmouth/hourglass_fort/basement" = "key_hourglass_fort",
  "Yarrowmouth/hourglass_fort/tunnel" = "key_hourglass_fort",
  "Yarrowmouth/hourglass_fort/hourglass_fort" = "key_hourglass_fort",
  "isle_of_storms/palace" = "key_palace_of_storms",
  "goatshead_island/spruce_head_shrine/spruce_head_shrine" = "key_spruce_head",
} --]]
--[[ local map_key_map = {
  Yarrowmouth/bear_catacombs/bear_catacombs = "key_bear_catacombs",
  oakhaven/fort_crow/fort_crow = "key_fort_crow",
  goatshead_island/caves/goat_caverns = "key_goat_caverns",
  goatshead_island/interiors/tunnels = "key_goat_tunnels",
  snapmast_reef/cemetery_of_the_waves/shipwreck_chain = "key_graveyard_of_the_waves",
  snapmast_reef/cemetery_of_the_waves/blackbeard_cabin = "key_graveyard_of_the_waves",
  Yarrowmouth/hourglass_fort/basement = "key_hourglass_fort",
  Yarrowmouth/hourglass_fort/tunnel = "key_hourglass_fort",
  Yarrowmouth/hourglass_fort/hourglass_fort = "key_hourglass_fort",
  isle_of_storms/palace = "key_palace_of_storms",
  goatshead_island/spruce_head_shrine/spruce_head_shrine = "key_spruce_head",
} --]]
local map_key_map = {}
  map_key_map["Yarrowmouth/bear_catacombs/bear_catacombs"] = "key_bear_catacombs"
  map_key_map["oakhaven/fort_crow/fort_crow"] = "key_fort_crow"
  map_key_map["ballast_harbor/pirate_vault"] = "key_ballast_council_building"
  map_key_map["ballast_harbor/willow_palace"] = "key_willow_palace"
  map_key_map["goatshead_island/caves/goat_caverns"] = "key_goat_caverns"
  map_key_map["goatshead_island/interiors/tunnels"] = "key_goat_tunnels"
  map_key_map["snapmast_reef/cemetery_of_the_waves/shipwreck_chain"] = "key_graveyard_of_the_waves"
  map_key_map["snapmast_reef/cemetery_of_the_waves/blackbeard_cabin"] = "key_graveyard_of_the_waves"
  map_key_map["Yarrowmouth/hourglass_fort/basement"] = "key_hourglass_fort"
  map_key_map["Yarrowmouth/hourglass_fort/tunnel"] = "key_hourglass_fort"
  map_key_map["Yarrowmouth/hourglass_fort/hourglass_fort"] = "key_hourglass_fort"
  map_key_map["isle_of_storms/palace"] = "key_palace_of_storms"
  map_key_map["goatshead_island/spruce_head_shrine/spruce_head_shrine"] = "key_spruce_head"

local key_item

local map_meta = sol.main.get_metatable"map"

map_meta:register_event("on_started", function(self)
	local map = self
  local game = map:get_game()
  key_item = map_key_map[map:get_id()] or nil
  if key_item and not sol.menu.is_started(small_key_menu) then
    sol.menu.start(game, small_key_menu)
  elseif sol.menu.is_started(small_key_menu) then
    sol.menu.stop(small_key_menu)
  end
end)

function small_key_menu:on_started()
  --update number of keys every 200ms or so
  small_key_menu:update_keys()
  sol.timer.start(sol.main.get_game():get_map(), 200, function() small_key_menu:update_keys() return true end)
end

function small_key_menu:update_keys()
  local game = sol.main.get_game()
  local key_amount = game:get_item(key_item):get_amount()
  key_surface:clear()
  for i = 1, key_amount do
    key_sprite:draw(key_surface, i * 12, 216)
  end
end

function small_key_menu:on_draw(dst)
  key_surface:draw(dst)
end


return small_key_menu