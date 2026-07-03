local shared = require("shared")

-- there are so many children of item prototypes, might as well run through all the entities too since only items have spoil_ticks.
-- log('these items have spoil ticks defined:')
-- for _, prototypes in pairs(data.raw) do
--   for _, prototype in pairs(prototypes) do
--     if prototype.spoil_ticks ~= nil then
--       log(prototype.type .. ':' .. prototype.name)
--       -- prototype.spoil_ticks = nil
--     end
--   end
-- end

-- the above code outputs this list, we're gonna curate it manually to avoid conflicts with other mods.

-- item:copper-bacteria
-- item:iron-bacteria
-- item:nutrients
-- item:captive-biter-spawner
-- item:biter-egg
-- item:pentapod-egg
-- capsule:raw-fish
-- capsule:yumako
-- capsule:jellynut
-- capsule:yumako-mash
-- capsule:jelly
-- capsule:bioflux
-- tool:agricultural-science-pack

local function remove_spoil_mechanic(prototype)
  prototype.spoil_ticks = nil

  -- https://mods.factorio.com/mod/no-spoilage/discussion/67718ed09706cacee2faa48f
  -- that mod has a valid usecase, however i don't want to always leave this un-niled, so for now only that mod has an exception.
  if mods["spoiling-plant"] == nil then
    prototype.spoil_result = nil
  end

  prototype.spoil_to_trigger_result = nil
end

for _, item in ipairs(shared.spoils) do
  -- log("no-spoilage-item-" .. item.name)
  if settings.startup["no-spoilage-item-" .. item.name].value then
    remove_spoil_mechanic(data.raw[item.type][item.name])
  end
end
