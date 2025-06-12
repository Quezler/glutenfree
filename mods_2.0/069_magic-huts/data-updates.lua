require("shared")

local entity_names = {
  mod_prefix .. "container-1",
  mod_prefix .. "container-2",
  mod_prefix .. "container-3",

  mod_prefix .. "crafter-a-1",
  mod_prefix .. "crafter-a-2",
  mod_prefix .. "crafter-a-3",

  mod_prefix .. "crafter-b-1",
  mod_prefix .. "crafter-b-2",
  mod_prefix .. "crafter-b-3",

  mod_prefix .. "eei-1",
  mod_prefix .. "eei-2",
  mod_prefix .. "eei-3",
}

for _, planet in pairs(data.raw["planet"]) do
  if planet.lightning_properties and planet.lightning_properties.exemption_rules then
    for _, entity_name in ipairs(entity_names) do
      table.insert(planet.lightning_properties.exemption_rules, {type = "id", string = entity_name})
    end
  end
end
