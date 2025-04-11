-- step 1
local old_mod_prefix = mod_prefix
mod_prefix = "se-"
Event = {addListener = function() end}

-- step 2
local CoreMiner = require("__space-exploration__.scripts.core-miner")

-- step 3
Event = nil
mod_prefix = old_mod_prefix

-- step 4

--- @since 2.2.0
return CoreMiner
