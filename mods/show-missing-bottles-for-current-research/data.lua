-- data.raw['gui-style']['default'].current_research_info_button.height = 42 + 10
-- data.raw['gui-style']['default'].current_research_info_button.bottom_margin = 4 + 20
data.raw['gui-style']['default'].current_research_info_button.bottom_padding = 4 + 20

data.raw['gui-style']['default'].show_missing_bottles_for_current_research_frame = {
  type = "frame_style",
  parent = "invisible_frame",
  horizontal_flow_style = {
    type = "horizontal_flow_style",
    horizontal_align = "right",
    -- vertical_align = "bottom",
    horizontally_stretchable = "on",
    -- vertically_stretchable = "on",
  }
}

data.raw['gui-style']['default'].show_missing_bottles_for_current_research_window = {
  type = "frame_style",
  parent = "invisible_frame",
  horizontal_flow_style = {
    type = "horizontal_flow_style",
    horizontal_align = "left",
    -- vertical_align = "bottom",
    -- horizontally_stretchable = "on",
    -- vertically_stretchable = "on",
  }
}

data.raw['gui-style']['default'].show_missing_bottles_for_current_research_label = {
  type = "label_style",
  -- font = "default-tiny-bold",
  -- font_color = {r=1, g=1, b=1, a=0.5},
}
