require("shared")

if mods["space-exploration"] then
  local product_name_blacklisted = util.list_to_map({
    -- more efficient when made from several catalogue tiers
    "se-astronomic-insight",
    "se-biological-insight",
    "se-energy-insight",
    "se-material-insight",

    -- more efficient when made from several insight colors
    "se-significant-data",

    -- more efficient when made with more types of observation data
    "se-astrometric-data",
  })

  for _, recipe in pairs(data.raw["recipe"]) do
    for _, result in pairs(recipe.results or {}) do
      if product_name_blacklisted[result.name] then
        data.raw["mod-data"][mod_prefix .. "recipe-name-blacklisted"].data[recipe.name] = true
      end
    end
  end
end

-- log(serpent.block(data.raw["mod-data"][mod_prefix .. "recipe-name-blacklisted"].data))

for _, entity_type in ipairs({"inserter", "loader", "loader-1x1"}) do
  for _, entity in pairs(data.raw[entity_type]) do
    for i = 1, 6 do
      table.insert(data.raw["container"][mod_prefix .. "container-" .. i].additional_pastable_entities, entity.name)
    end
  end
end
