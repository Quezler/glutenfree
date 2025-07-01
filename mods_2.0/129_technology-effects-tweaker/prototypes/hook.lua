require("namespace")

local original_technology_effects = {
  type = "mod-data",
  name = mod_prefix .. "original-technology-effects",
  data = {},
}

for _, technology in pairs(data.raw["technology"]) do
  original_technology_effects.data[technology.name] = table.deepcopy(technology.effects or {})
  technology.seen_by_technology_effects_tweaker_as = technology.name -- adds itself to the prototype history of all technologies as a "last touched by" check
end

data:extend{original_technology_effects}
