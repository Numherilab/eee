local sparkle = ...
local game = sparkle:get_game()
local map = sparkle:get_map()
local is_flail = false

local damage = 10

sparkle:set_can_traverse("crystal", true)
sparkle:set_can_traverse("crystal_block", true)
sparkle:set_can_traverse("hero", true)
sparkle:set_can_traverse("jumper", true)
sparkle:set_can_traverse("stairs", true)
sparkle:set_can_traverse("stream", true)
sparkle:set_can_traverse("switch", true)
sparkle:set_can_traverse("teletransporter", true)
sparkle:set_can_traverse_ground("deep_water", true)
sparkle:set_can_traverse_ground("shallow_water", true)
sparkle:set_can_traverse_ground("hole", true)
sparkle:set_can_traverse_ground("lava", true)
sparkle:set_can_traverse_ground("prickles", true)
sparkle:set_can_traverse_ground("low_wall", true)

sparkle:set_drawn_in_y_order(true)

function sparkle:on_created()
  damage = game:get_value("sword_damage")
end

function sparkle:set_damage(amount)
  damage = amount
end

function sparkle:set_is_flail(bool)
  is_flail = bool
end


-- Hurt enemies.
sparkle:add_collision_test("sprite", function(sparkle, entity)
  if entity:get_type() == "enemy" then
    local enemy = entity
    local reaction = enemy:get_attack_consequence("sword")
    if reaction ~= "protected" and reaction ~= "ignored" then
     enemy:hurt(damage)
    end
    if is_flail then enemy:hit_by_toss_ball() end
  end
end)