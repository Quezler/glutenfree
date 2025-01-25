local mod_prefix = "deconstruction-planner-toggle-entity-with-pipette--"

-- whilst they are two different actions the lua event fires regardless of which of the two the game will actually run,
-- therefor we only need one of the "Q" key events and just figure out in the control stage which of the 2 it actually is.

-- data:extend({
--   {
--     type = "custom-input", key_sequence = "",
--     name = mod_prefix .. "clear-cursor",
--     linked_game_control = "clear-cursor",
--     include_selected_prototype = true,
--   }
-- })

data:extend({
  {
    type = "custom-input", key_sequence = "",
    name = mod_prefix .. "pipette",
    linked_game_control = "pipette",
    include_selected_prototype = true,
  }
})
