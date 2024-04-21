-- step 1
mod_prefix = 'se-'
Event = {addListener = function() end}
core_util = require('__core__/lualib/util.lua')
SpaceshipClamp = require('__space-exploration__.scripts.spaceship-clamp')

-- step 2
local Spaceship = require('__space-exploration__.scripts.spaceship')

-- step 3
SpaceshipClamp = nil
core_util = nil
Event = nil
mod_prefix = nil

-- step 4
return Spaceship
