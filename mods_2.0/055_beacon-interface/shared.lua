local mod_prefix = "beacon-interface--"

local effects = {
  "speed",
  "productivity",
  "consumption",
  "pollution",
  "quality",
}

local module_number_to_strength = {}
for i = 1, 16 do
  local two_character_number = string.format("%02d", i)
  if i == 16 then
    module_number_to_strength[two_character_number] = -math.pow(2, i - 2)
  else
    module_number_to_strength[two_character_number] =  math.pow(2, i - 1)
  end
end

local module_name_to_effect_and_strength = {}
for _, effect in ipairs(effects) do
  for i = 1, 16 do
    local two_character_number = string.format("%02d", i)
    local name = string.format(mod_prefix .. "%s-module-%s", effect, two_character_number)
    module_name_to_effect_and_strength[name] = {effect, module_number_to_strength[two_character_number]}
  end
end

local function get_empty_effects()
  return {
    speed = 0,
    productivity = 0,
    consumption = 0,
    pollution = 0,
    quality = 0,
  }
end

return {
  effects = effects,
  min_strength = -32768,
  max_strength =  32767,
  module_number_to_strength = module_number_to_strength,
  module_name_to_effect_and_strength = module_name_to_effect_and_strength,
  get_empty_effects = get_empty_effects,
}
