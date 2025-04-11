-- step 1
mod_prefix = 'se-'
Event = {addListener = function() end}

-- step 2
local CoreMiner = require('__space-exploration__.scripts.core-miner')

-- step 3
Event = nil
mod_prefix = nil

-- step 4
return CoreMiner
