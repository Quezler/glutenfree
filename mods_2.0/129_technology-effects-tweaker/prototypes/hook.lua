require("namespace")

local original_technology_effects = {
  type = "mod-data",
  name = mod_prefix .. "original-technology-effects",
  data = {},
}

for _, technology in pairs(data.raw["technology"]) do
  original_technology_effects.data[technology.name] = table.deepcopy(technology.effects or {})
end

data:extend{original_technology_effects}
