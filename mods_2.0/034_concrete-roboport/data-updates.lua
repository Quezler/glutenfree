require("shared")

for _, planet in pairs(data.raw["planet"]) do
  if planet.lightning_properties then
    table.insert(planet.lightning_properties.exemption_rules, {
      type = "id",
      string = mod_prefix .. "tile",
    })
  end
end
