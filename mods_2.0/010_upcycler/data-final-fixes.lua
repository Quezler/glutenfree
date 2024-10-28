if settings.startup["upcycling-no-quality-modules"].value then
  for _, module in pairs(data.raw["module"]) do
    if module.effect.quality ~= nil then

      -- hide modules that have possitive quality
      if module.effect.quality > 0 then
        module.hidden = true
        data.raw["recipe"][module.name].hidden = true
      end

      -- and set both positive and negative qualities to nil
      module.effect.quality = nil
    end
  end
end

-- i came too far in this mod's development to realize furnace slots cannot be forced to hold a non product output,
-- tbh its on me for testing that at the time by lua-inserting iron plates directly into a recycler's output slot,
-- so yea ima quick and dirty add one of each item as a potential output just so i can call it a day and go zzzz.
local results = assert(data.raw["recipe"]["upcycling-output-slots"].results)
for type_name in pairs(defines.prototypes.item) do
  if data.raw[type_name] then
    for k, item in pairs(data.raw[type_name]) do
      table.insert(results, {type = "item", name = k, amount = 1})
    end
  end
end
