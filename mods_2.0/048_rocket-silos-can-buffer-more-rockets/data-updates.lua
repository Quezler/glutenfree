
local mod_prefix = "rocket-silos-can-buffer-more-rockets--"

local multiplier = settings.startup[mod_prefix .. "rocket-parts-storage-cap-multiplier"].value

local rocket_silo = data.raw["rocket-silo"]["rocket-silo"]
rocket_silo.rocket_parts_storage_cap = rocket_silo.rocket_parts_required * multiplier
