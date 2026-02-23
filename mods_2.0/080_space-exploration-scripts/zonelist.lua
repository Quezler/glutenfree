-- step 1
local old_mod_prefix = mod_prefix
mod_prefix = "se-"
Event = {addListener = function() end}

-- step 2
local Zonelist = require("__space-exploration__.scripts.zonelist")

-- step 3
Event = nil
mod_prefix = old_mod_prefix

-- step 4

--- @since 2.1.0
return Zonelist
