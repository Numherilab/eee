local hazel = {}

function hazel:summon(hero)
  local map = hero:get_map()
  local x,y,z = hero:get_position()
  map:create_custom_entity{
    x=x, y=y, layer=z, direction=3, width=16, height=16,
    sprite = "npc/hazel",
    model = "ally",
    name = "hazel"
  }
end

return hazel