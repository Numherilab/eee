-- Lua script of map Limestone Island/caves/lighthouse.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local switch_1 = false
local switch_2 = false

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  if game:get_value("limestone_lighthouses_torches") == true then
    light_limestone_lighthouse_torches()
  end
  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

--light the torches
local function light_limestone_lighthouse_torches()
  torch_1:set_enabled()
  torch_2:set_enabled()
  torch_3:set_enabled()
  torch_4:set_enabled()
end


--switch 1
function sword_switch_1:on_activated()
 switch_1 = sword_switch_1:is_activated()
  if switch_2 == true then
    game:set_value("limestone_lighthouse_lit", true)
    sol.audio.play_sound("secret")
    light_limestone_lighthouse_torches()
  end

  sol.timer.start(500, function()
    sword_switch_1:set_activated(false)
    switch_1 = false
  end)
end

-- switch 2
function sword_switch_2:on_activated()
 switch_2 = sword_switch_2:is_activated()
  if switch_1 == true then
    game:set_value("limestone_lighthouse_lit", true)
    sol.audio.play_sound("secret")
    light_limestone_lighthouse_torches()
  end

  sol.timer.start(500, function()
    sword_switch_2:set_activated(false)
    switch_2 = false
  end)
end

