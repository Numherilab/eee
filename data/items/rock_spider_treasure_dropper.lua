require("scripts/multi_events")

local item = ...

-- When it is created, this item creates another item randomly chosen
-- and then destroys itself.

local probability = 50 -- chance out of 100 that this item show up

item:register_event("on_pickable_created", function(self, pickable)

 random = math.random(100)
 if random < probability then
    local map = pickable:get_map()
    local x, y, layer = pickable:get_position()
    map:create_pickable{
      layer = layer,
      x = x,
      y = y,
      treasure_name = "rock_spider_treasure",
      treasure_variant = 1,
    }
  end
  pickable:remove()
end)
