-- step 1
mod_prefix = "se-"
Event = {addListener = function() end}

-- step 2
local Meteor = require("__space-exploration__.scripts.meteor")

-- step 3
Event = nil
mod_prefix = nil

-- step 4

--- @since 2.5.0
return Meteor
