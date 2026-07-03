local mod_prefix = "change-recipe-quality-without-re-selecting-recipe-"

data:extend({
  {
    type = "custom-input", key_sequence = "",
    name = mod_prefix .. "cycle-quality-up",
    linked_game_control = "cycle-quality-up",
    include_selected_prototype = true,
  }
})

data:extend({
  {
    type = "custom-input", key_sequence = "",
    name = mod_prefix .. "cycle-quality-down",
    linked_game_control = "cycle-quality-down",
    include_selected_prototype = true,
  }
})
