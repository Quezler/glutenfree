local crc = require("crc")
local mod_prefix = "csrsbsy-"

local old_name = mod_prefix .. "radar-barrel"
local new_name = mod_prefix .. "radar-barrel-1" .. crc(mods)

data.raw["item"][old_name].name = new_name
data.raw["item"][new_name] = data.raw["item"][old_name]
data.raw["item"][old_name] = nil
