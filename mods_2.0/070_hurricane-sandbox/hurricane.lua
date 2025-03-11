local Hurricane = {}

function Hurricane.assembling_machine(directory, name)
  local config = require(string.format("%s/%s/%s.lua", directory, name, name))

  error(serpent.block(config))
end

return Hurricane
