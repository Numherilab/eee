--skull switch order:
--2,4,3,1

local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(4)
  sol.menu.start(map, lighting_effects)
end)


--Barrow Door
local switch_index = 1
local switches = {"skull_2", "skull_4", "skull_3", "skull_1"}

for entity in map:get_entities("skull_") do
  function entity:on_interaction()
    map:press_switch(self:get_name())
  end
end

function map:press_switch(name)
  if switches[switch_index] == name then
    sol.audio.play_sound"switch"
    switch_index = switch_index + 1
    if switch_index == (#switches + 1) then
      sol.audio.play_sound"switch"
      map:open_doors("skull_door")
    end
  else
    sol.audio.play_sound"wrong"
    switch_index = 1
  end
end
