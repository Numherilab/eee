local map = ...
local game = map:get_game()
game.respawn_screen = require("scripts/menus/respawn_screen")

function map:on_started()
    hero:freeze()
    if not sol.menu.is_started(game.respawn_screen) then
      sol.menu.start(game, game.respawn_screen)
    end
    -- hero:teleport(game:get_starting_location())
    hero:teleport(game:get_value"respawn_map")

end

function map:on_opening_transition_finished()
--keep this function defined to not set the respawn map as a map to return to after respawning
end
