require("scripts/multi_events")

local item = ...

-- When it is created, this item creates another item randomly chosen
-- and then destroys itself.

local probability = 80 -- chance out of 100 that berries show up

item:register_event("on_pickable_created", function(self, pickable)

 random = math.random(100)
 if random < probability then
    local map = pickable:get_map()
    local x, y, layer = pickable:get_position()
    map:create_pickable{
      layer = layer,
      x = x,
      y = y,
      treasure_name = "berries",
      treasure_variant = 1, --this line is optional, I'll keep it in case things change with the berries item.
    }
  end
  pickable:remove()
end)
