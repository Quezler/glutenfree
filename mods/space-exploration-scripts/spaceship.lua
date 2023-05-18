-- step 1
mod_prefix = 'se-'
Event = {addListener = function() end}
SpaceshipClamp = require('__space-exploration__.scripts.spaceship-clamp')

-- step 2
local Spaceship = require('__space-exploration__.scripts.spaceship')

-- step 3
SpaceshipClamp = nil
Event = nil
mod_prefix = nil

-- step 4
return Spaceship
