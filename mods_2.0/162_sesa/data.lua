local resources = {
  {name = "calcite"},
  {name = "sulfuric-acid-geyser", product = "sulfuric-acid"},
  {name = "tungsten-ore"},
  {name = "scrap"},
  {name = "lithium-brine"},
  {name = "fluorine-vent", product = "fluorine"},
}

for _, resource in ipairs(resources) do
  resource.product = resource.product or resource.name

  -- prevent zones from having space age ores as their primary resource or as ore
  data.raw["mod-data"]["se-universe-resource-word-rules"].data[resource.name] = {
    forbid_space = true,
    forbid_orbit = true,
    forbid_belt = true,
    forbid_field = true,
    forbid_planet = true,
    forbid_homeworld = true,
  }

  se_core_fragment_resources = se_core_fragment_resources or {}
  se_core_fragment_resources[resource.product] = se_core_fragment_resources[resource.product] or {
    multiplier = 0, -- do not create a pulverizer recipe for this resource/fragment
    omni_multiplier = 0, -- do not output this resource when crushing omni fragments
  }
end
