local Shared = {}

Shared.resources = {
  {name = "calcite"},
  {name = "sulfuric-acid-geyser", product = "sulfuric-acid"},
  {name = "tungsten-ore"},
  {name = "scrap"},
  {name = "lithium-brine"},
  {name = "fluorine-vent", product = "fluorine"},
}

Shared.resources_name_list = {}
for _, resource in ipairs(Shared.resources) do
  table.insert(Shared.resources_name_list, resource.name)
end

return Shared
