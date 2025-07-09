-- step 1
mod_prefix = "se-"
Event = {addListener = function() end}

-- step 2
local Lifesupport = require("__space-exploration__.scripts.lifesupport")

-- step 3
Event = nil
mod_prefix = nil

-- step 4
--- @since 2.6.0
return Lifesupport
