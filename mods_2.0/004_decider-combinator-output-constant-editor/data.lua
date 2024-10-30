data:extend({
  {
    type = 'custom-input',
    name = 'dcoce-i',
    key_sequence = 'I',
    include_selected_prototype = true,
  }
})

local selection_tool = {
  type = "selection-tool",
  name = "decider-combinator-output-constant-detector",

  icon = data.raw["item"]["decider-combinator"].icon,
  stack_size = 1,
  flags = {"not-stackable", "only-in-cursor"},
  select = {
    border_color = {1, 1, 0}, -- yellow
    cursor_box_type = "entity",
    mode = {"blueprint"},
    entity_type_filters = {"decider-combinator"},
  }
}

selection_tool.alt_select = selection_tool.select

data:extend{selection_tool}
