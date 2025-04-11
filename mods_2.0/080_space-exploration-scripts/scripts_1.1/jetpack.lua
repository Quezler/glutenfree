-- step 1
Event = {addListener = function() end}

-- step 2
local oed = script.get_event_handler(defines.events.on_entity_damaged)
local odst = script.get_event_handler(defines.events.on_player_driving_changed_state)
local Jetpack = require('__jetpack__.scripts.jetpack')
script.on_event(defines.events.on_player_driving_changed_state, odst)
script.on_event(defines.events.on_entity_damaged, oed)

-- step 3
Event = nil

-- step 4
return Jetpack
