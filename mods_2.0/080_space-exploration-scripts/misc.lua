function require_SE(path)
  local old_mod_prefix = mod_prefix
  local old_mod_prefix_snake_case = mod_prefix_snake_case
  local old_event = Event
  local old_util = util

  mod_prefix = "se-"
  mod_prefix_snake_case = "se_"
  Event = {
    addListener = function() end,
    addOnEntityCreatedListeners = function() end,
    addOnEntityRemovedListeners = function() end,
  }
  util = require("util")

  local module = require(path)

  mod_prefix = old_mod_prefix
  mod_prefix_snake_case = old_mod_prefix_snake_case
  Event = old_event
  util = old_util

  return module
end
