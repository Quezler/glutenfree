local mod_data = data.raw["mod-data"]["minable-resources"].data

-- for _, node_info in pairs(mod_data.node_info) do
  
-- end

-- local function recipe_is_supported(recipe)
--   for _, ingredient in ipairs(recipe.ingredients or {}) do
--     if ingredient.type == "item" then
--       local node_name = mod_data.item_ingredients_map[ingredient.name]
--       if node_name then
--         return true
--       end
--     end
--   end
-- end

-- local multiplier = 10

-- for _, recipe in pairs(data.raw["recipe"]) do
--   if recipe_is_supported(recipe) then
--     local other = table.deepcopy(recipe)
--     other.name = other.name .. "-node"
--     other.localised_name = {"item-name." .. recipe.name}

--     for _, ingredient in ipairs(other.ingredients) do
--       ingredient.amount = (ingredient.amount or 1) * multiplier
--       if ingredient.type == "item" then
--         local node_name = mod_data.item_ingredients_map[ingredient.name]
--         if node_name then
--           ingredient.name = node_name
--         end
--       end
--     end

--     for _, product in ipairs(other.results or {}) do
--       product.amount = (product.amount or 1) * multiplier
--     end

--     other.energy_required = (other.energy_required or 0.5) * multiplier
--     other.hide_from_player_crafting = true
--     data:extend{other}
--   end
-- end

-- for _, furnace in pairs(data.raw["furnace"]) do
--   data.raw["furnace"][furnace.name] = nil
--   furnace.type = "assembling-machine"
--   data.raw["assembling-machine"][furnace.name] = furnace
-- end
