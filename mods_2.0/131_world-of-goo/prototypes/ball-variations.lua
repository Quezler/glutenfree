local variations = {}

for i = 1, 16 do
  local scale = 0.5
  local multiplier = 32 * scale
  variations[i] = {
    {icon = mod_directory .. "/graphics/balls/common-body.png", icon_size = 64, scale = scale},

    {icon = mod_directory .. "/graphics/balls/generic-eye-2.png", icon_size = 23, shift = {-0.50 * multiplier, -0.10 * multiplier}, scale = scale, floating = true},
    {icon = mod_directory .. "/graphics/balls/generic-pupil.png", icon_size =  8, shift = {-0.45 * multiplier, -0.15 * multiplier}, scale = scale, floating = true},
    {icon = mod_directory .. "/graphics/balls/generic-eye-1.png", icon_size = 32, shift = { 0.30 * multiplier, -0.30 * multiplier}, scale = scale, floating = true},
    {icon = mod_directory .. "/graphics/balls/generic-pupil.png", icon_size =  8, shift = { 0.35 * multiplier, -0.35 * multiplier}, scale = scale, floating = true},
  }
end

return variations
