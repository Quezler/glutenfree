require("shared")

local entity_names = {}

for i = 1, 6 do
  table.insert(entity_names, mod_prefix .. "container-" .. i)
  table.insert(entity_names, mod_prefix .. "crafter-a-" .. i)
  table.insert(entity_names, mod_prefix .. "crafter-b-" .. i)
  table.insert(entity_names, mod_prefix .. "eei-" .. i)
end

for _, planet in pairs(data.raw["planet"]) do
  if planet.lightning_properties and planet.lightning_properties.exemption_rules then
    for _, entity_name in ipairs(entity_names) do
      table.insert(planet.lightning_properties.exemption_rules, {type = "id", string = entity_name})
    end
  end
end
