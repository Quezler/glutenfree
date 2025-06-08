require("shared")

for _, planet in pairs(data.raw["planet"]) do
  if planet.lightning_properties and planet.lightning_properties.exemption_rules then
    table.insert(planet.lightning_properties.exemption_rules, {
      type = "id",
      string = mod_prefix .. "container-1",
    })
    table.insert(planet.lightning_properties.exemption_rules, {
      type = "id",
      string = mod_prefix .. "container-2",
    })
    table.insert(planet.lightning_properties.exemption_rules, {
      type = "id",
      string = mod_prefix .. "container-3",
    })
  end
end
