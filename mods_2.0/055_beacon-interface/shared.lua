local effects = {
  "speed",
  "productivity",
  "consumption",
  "pollution",
  "quality",
}

local module_number_to_value = {}
for i = 1, 16 do
  local two_character_number = string.format("%02d", i)
  if i == 16 then
    module_number_to_value[two_character_number] = -math.pow(2, i - 2)
  else
    module_number_to_value[two_character_number] =  math.pow(2, i - 1)
  end
end

return {
  effects = effects,
  min_strength = -32768,
  max_strength =  32767,
  module_number_to_value = module_number_to_value,
}
