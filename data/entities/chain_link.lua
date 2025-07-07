--For items like a ball and chain that need some links between the relevant part and the entity that's swinging them.

local entity = ...
local game = entity:get_game()
local map = entity:get_map()

entity:set_can_traverse("crystal", true)
entity:set_can_traverse("crystal_block", true)
entity:set_can_traverse("hero", true)
entity:set_can_traverse("jumper", true)
entity:set_can_traverse("stairs", false)
entity:set_can_traverse("stream", true)
entity:set_can_traverse("switch", true)
entity:set_can_traverse("teletransporter", true)
entity:set_can_traverse_ground("deep_water", true)
entity:set_can_traverse_ground("shallow_water", true)
entity:set_can_traverse_ground("hole", true)
entity:set_can_traverse_ground("lava", true)
entity:set_can_traverse_ground("prickles", true)
entity:set_can_traverse_ground("low_wall", true)

-- Event called when the custom entity is initialized.
function entity:on_created()

end
