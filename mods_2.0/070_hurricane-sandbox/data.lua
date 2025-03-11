require("shared")

local Hurricane = require("graphics/hurricane")
local skin = Hurricane.crafter({
  directory = mod_directory .. "factorio-sprites",
  name = "radio-station",
  width = 1280, height = 870,
  total_frames = 20, rows = 3, -- custom
  shadow_width = 400, shadow_height = 350,
  shift = {0, 0.25}, -- custom
})
