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
