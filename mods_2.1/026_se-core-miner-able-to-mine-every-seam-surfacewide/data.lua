require("namespace")

local core_miner = data.raw["mining-drill"]["se-core-miner-drill"]
core_miner.allowed_effects = {"consumption"} -- linearly increases pollution too
core_miner.effect_receiver = {
  uses_module_effects = false,
  uses_beacon_effects = true,
  uses_surface_effects = false,
}

local beacon_interface = table.deepcopy(data.raw["beacon"]["beacon-interface--beacon-tile"])
beacon_interface.name = mod_prefix .. "beacon-interface"
data:extend{beacon_interface}
