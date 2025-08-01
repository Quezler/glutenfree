local variations = {}

local function math_random(low, high)
  return low + math.random() * (high - low)
end

for i = 1, 16 do
  local scale = 0.5
  local multiplier = 32 * scale

  local body_scale = math_random(0.7, 1.0)

  local left_eye_shift = {-math_random(0.30, 0.50) * multiplier, -math_random(0.10, 0.30) * multiplier}
  local right_eye_shift = {math_random(0.30, 0.50) * multiplier, -math_random(0.20, 0.40) * multiplier}

  variations[i] = {
    {icon = "__core__/graphics/empty.png", icon_size = 64, scale = scale},
    {icon = mod_directory .. "/graphics/balls/common-body.png", icon_size = 64, scale = scale * body_scale},

    {icon = mod_directory .. "/graphics/balls/generic-eye-2.png", icon_size = 23, shift = left_eye_shift, scale = scale, floating = true},
    {icon = mod_directory .. "/graphics/balls/generic-pupil.png", icon_size =  8, shift = left_eye_shift, scale = scale, floating = true},
    {icon = mod_directory .. "/graphics/balls/generic-eye-1.png", icon_size = 32, shift = right_eye_shift, scale = scale, floating = true},
    {icon = mod_directory .. "/graphics/balls/generic-pupil.png", icon_size =  8, shift = right_eye_shift, scale = scale, floating = true},
  }
end

return variations
