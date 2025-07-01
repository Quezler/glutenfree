require("namespace")

if settings.startup[mod_prefix .. "stage"].value == "data-final-fixes" then
  require("prototypes.hook")
end

-- testing technologies removed or added afterwards
data.raw["technology"]["nuclear-fuel-reprocezzing"] = table.deepcopy(data.raw["technology"]["nuclear-fuel-reprocessing"])
data.raw["technology"]["nuclear-fuel-reprocezzing"].name = "nuclear-fuel-reprocezzing"
data.raw["technology"]["nuclear-fuel-reprocessing"] = nil
