local function read_utility_constants(utility_constants)
  if utility_constants.type ~= "utility-constants" then return end
  if utility_constants.name ~= "default" then return end

  for k, _ in pairs(utility_constants) do
    local v = prototypes.utility_constants[k]
    if v == nil or false then
      log(string.format("%s: %s", k, v))
    end
  end
end

data = {
  extend = function(self, otherdata)
    read_utility_constants(otherdata[1])
  end
}

require("__core__.prototypes.style")
require("__core__.prototypes.utility-constants")
