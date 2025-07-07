local mapping = {}

mapping.button = {
  [0] = "action",
  [1] = "attack",
  [2] = "item_1",
  [3] = "item_2",
  [11] = "up",
  [12] = "down",
  [13] = "left",
  [14] = "right",
}

--[[
mapping.button = {
  {0, "action"},
  {1, "attack"},
  {2, "item_1"},
  {3, "item_2"},
  {11, "up"},
  {12, "down"},
  {13, "left"},
  {14, "right"},
}
--]]

return mapping

--game:set_command_joypad_binding(command, joypad_string)
