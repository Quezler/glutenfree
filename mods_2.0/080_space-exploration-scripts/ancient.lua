-- step 1
mod_prefix = "se-"
core_util = require("__core__/lualib/util.lua")
Event = {addListener = function() end}

-- step 2
local Ancient = require("__space-exploration__.scripts.ancient")

-- step 3
Event = nil
core_util = nil
mod_prefix = nil

-- @since 2.4.0
return Ancient
