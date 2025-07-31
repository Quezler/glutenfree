require("namespace")

local ball_variations = require("prototypes.ball-variations")

for i, variation in ipairs(ball_variations) do
  local i2 = string.format("%02d", i)
  data:extend{{
    type = "item",
    name = "common-goo-ball--" .. i2,
    icons = variation,
    stack_size = 1,
  }}
end
