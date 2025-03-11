require("util")

local Hurricane = {}

function Hurricane.assembling_machine(directory)
  local parts = util.split(directory, "/")
  local config = require(directory .. "/" .. parts[#parts])

  -- error(serpent.block(config))
end

return Hurricane
