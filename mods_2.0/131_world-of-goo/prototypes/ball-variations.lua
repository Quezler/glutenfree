local variations = {}

for i = 1, 16 do
  local layers = {}

  table.insert(layers, {filename = mod_directory .. "/graphics/balls/common-body.png", size = 64, scale = 0.5})

  table.insert(layers, {filename = mod_directory .. "/graphics/balls/generic-eye-2.png", size = 23, shift = {-0.50 * 0.5, -0.10 * 0.5}, scale = 0.5})
  table.insert(layers, {filename = mod_directory .. "/graphics/balls/generic-pupil.png", size =  8, shift = {-0.45 * 0.5, -0.15 * 0.5}, scale = 0.5})
  table.insert(layers, {filename = mod_directory .. "/graphics/balls/generic-eye-1.png", size = 32, shift = { 0.30 * 0.5, -0.30 * 0.5}, scale = 0.5})
  table.insert(layers, {filename = mod_directory .. "/graphics/balls/generic-pupil.png", size =  8, shift = { 0.35 * 0.5, -0.35 * 0.5}, scale = 0.5})

  table.insert(variations, {layers = layers})
end

return variations
