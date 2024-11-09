local crc = require("crc")
local mod_prefix = "csrsbsy-"

local old_name = mod_prefix .. "radar-barrel"
local new_name = mod_prefix .. "radar-barrel-" .. crc(serpent.line({mods, data}))

data.raw["item"][old_name].name = new_name
data.raw["item"][new_name] = data.raw["item"][old_name]
data.raw["item"][old_name] = nil

-- log('crc start') -- 1.467
-- serpent.line(data)
-- log('crc end') -- 3.616
-- error()

-- log('crc start') -- 1.429
-- crc(serpent.line(data))
-- log('crc end') -- 4.855
-- error()

-- 3.4 seconds, not great not terrible
-- ofc serpenting the entire data and then manually running a lua crc on it is slow, something more practical is required (eventually),
-- it just needs to make sure there is a new name each time on_configuration_changed would trigger, aka mod names, versions, and all raw.
