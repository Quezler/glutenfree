-- step 1
mod_prefix = "se-"
Event = {addListener = function() end}

-- step 2
local GuiCommon = require("__space-exploration__.scripts.gui-common")

-- step 3
Event = nil
mod_prefix = nil

-- step 4
--- @since 2.7.0
return GuiCommon
