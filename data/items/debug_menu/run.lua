local item = ...
local game = item:get_game()

function item:on_started()
  local name = item:get_name():gsub("/", "_")
  item:set_savegame_variable("possession_" .. name)
end

function item:on_using()
  local hero = game:get_hero()
  if hero:get_walking_speed() == 300 then
    hero:set_walking_speed(debug.normal_walking_speed)
  else
    debug.normal_walking_speed = hero:get_walking_speed()
    hero:set_walking_speed(300)
  end
  item:set_finished()
end
