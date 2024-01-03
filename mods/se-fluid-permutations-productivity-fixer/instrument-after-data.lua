local function productivity_supported(recipe_name)
  for _, whitelisted_recipe_name in pairs(data.raw.module['productivity-module'].limitation) do
    if whitelisted_recipe_name == recipe_name then
      return true
    end
  end

  return false
end

local allow_productivity = {}

for _,recipe in pairs(data.raw.recipe) do
  local recipe_name = string.match(recipe.name, "(.-)-fp-")
  if recipe_name and data.raw['recipe'][recipe_name] then
    -- log(string.format('%s (%s)', recipe.name, recipe_name))

    if productivity_supported(recipe_name) then
      if not productivity_supported(recipe.name) then
        log(string.format('%s (%s)', recipe.name, recipe_name))
        table.insert(allow_productivity, recipe_name)
      end
    end
  end
end

log(serpent.block(allow_productivity))

-- 3.364 Script @__se-fluid-permutations-productivity-fixer__/instrument-after-data.lua:18: se-lattice-pressure-vessel-fp-da-i1-r0 (se-lattice-pressure-vessel)
-- 3.366 Script @__se-fluid-permutations-productivity-fixer__/instrument-after-data.lua:18: se-cryonite-ion-exchange-beads-fp-da-i1-r0 (se-cryonite-ion-exchange-beads)
-- 3.366 Script @__se-fluid-permutations-productivity-fixer__/instrument-after-data.lua:18: se-cryonite-lubricant-fp-da-i1-r0 (se-cryonite-lubricant)
-- 3.366 Script @__se-fluid-permutations-productivity-fixer__/instrument-after-data.lua:18: se-iridium-powder-fp-da-i1-r0 (se-iridium-powder)
-- 3.366 Script @__se-fluid-permutations-productivity-fixer__/instrument-after-data.lua:18: se-naquium-refined-fp-da-i1-r0 (se-naquium-refined)
-- 3.366 Script @__se-fluid-permutations-productivity-fixer__/instrument-after-data.lua:18: se-naquium-ingot-fp-da-i1-r0 (se-naquium-ingot)
-- 3.366 Script @__se-fluid-permutations-productivity-fixer__/instrument-after-data.lua:18: se-vulcanite-block-fp-da-i1-r0 (se-vulcanite-block)
-- 3.366 Script @__se-fluid-permutations-productivity-fixer__/instrument-after-data.lua:18: se-vulcanite-ion-exchange-beads-fp-da-i1-r0 (se-vulcanite-ion-exchange-beads)
-- 3.366 Script @__se-fluid-permutations-productivity-fixer__/instrument-after-data.lua:18: oil-processing-heavy-fp-da-i1-r1 (oil-processing-heavy)
-- 3.366 Script @__se-fluid-permutations-productivity-fixer__/instrument-after-data.lua:18: oil-processing-heavy-fp-da-i1-r2 (oil-processing-heavy)
-- 3.366 Script @__se-fluid-permutations-productivity-fixer__/instrument-after-data.lua:18: oil-processing-heavy-fp-da-i1-r3 (oil-processing-heavy)
-- 3.366 Script @__se-fluid-permutations-productivity-fixer__/instrument-after-data.lua:18: oil-processing-heavy-fp-da-i1-r4 (oil-processing-heavy)
-- 3.366 Script @__se-fluid-permutations-productivity-fixer__/instrument-after-data.lua:18: oil-processing-heavy-fp-da-i1-r5 (oil-processing-heavy)
-- 3.366 Script @__se-fluid-permutations-productivity-fixer__/instrument-after-data.lua:18: oil-processing-heavy-fp-da-i1-r6 (oil-processing-heavy)
-- 3.366 Script @__se-fluid-permutations-productivity-fixer__/instrument-after-data.lua:18: oil-processing-heavy-fp-da-i2-r1 (oil-processing-heavy)
-- 3.366 Script @__se-fluid-permutations-productivity-fixer__/instrument-after-data.lua:18: oil-processing-heavy-fp-da-i2-r2 (oil-processing-heavy)
-- 3.366 Script @__se-fluid-permutations-productivity-fixer__/instrument-after-data.lua:18: oil-processing-heavy-fp-da-i2-r3 (oil-processing-heavy)
-- 3.366 Script @__se-fluid-permutations-productivity-fixer__/instrument-after-data.lua:18: oil-processing-heavy-fp-da-i2-r4 (oil-processing-heavy)
-- 3.366 Script @__se-fluid-permutations-productivity-fixer__/instrument-after-data.lua:18: oil-processing-heavy-fp-da-i2-r5 (oil-processing-heavy)

-- 3.469 Script @__se-fluid-permutations-productivity-fixer__/instrument-after-data.lua:27: {
--   "se-lattice-pressure-vessel",
--   "se-cryonite-ion-exchange-beads",
--   "se-cryonite-lubricant",
--   "se-iridium-powder",
--   "se-naquium-refined",
--   "se-naquium-ingot",
--   "se-vulcanite-block",
--   "se-vulcanite-ion-exchange-beads",
--   "oil-processing-heavy",
--   "oil-processing-heavy",
--   "oil-processing-heavy",
--   "oil-processing-heavy",
--   "oil-processing-heavy",
--   "oil-processing-heavy",
--   "oil-processing-heavy",
--   "oil-processing-heavy",
--   "oil-processing-heavy",
--   "oil-processing-heavy",
--   "oil-processing-heavy"
-- }

error('who needs graphics anyways?')
