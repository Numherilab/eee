local movement_patterns = {}

function movement_patterns:initialize(enemy)
    local game = enemy:get_game()
    local map = enemy:get_map()
    local hero = map:get_hero()
    function circle_hero(radius, radius_speed)
        local m = sol.movement.create("circle")
        m:set_center(hero)
        m:set_radius(radius)
        m:set_radius_speed(radius_speed)
        m:start(enemy)
    end
end

return movement_patterns