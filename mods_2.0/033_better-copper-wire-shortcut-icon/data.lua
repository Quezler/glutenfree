local copper_tint = settings.startup["better-copper-wire-shortcut-icon--copper-tint"].value --[[@as Color]]

local copper_shortcut = data.raw["shortcut"]["give-copper-wire"]

copper_shortcut.icon = nil
copper_shortcut.icon_size = nil
copper_shortcut.small_icon = nil
copper_shortcut.small_icon_size = nil

copper_shortcut.icons = {
  {icon_size = 56, icon = "__better-copper-wire-shortcut-icon__/graphics/icons/shortcut-toolbar/mip/new-copper-wire-x56-tint.png", tint = copper_tint},
  {icon_size = 56, icon = "__better-copper-wire-shortcut-icon__/graphics/icons/shortcut-toolbar/mip/new-copper-wire-x56.png"},
}

copper_shortcut.small_icons = {
  {icon_size = 26, icon = "__better-copper-wire-shortcut-icon__/graphics/icons/shortcut-toolbar/mip/new-copper-wire-x26-tint.png", tint = copper_tint},
  {icon_size = 26, icon = "__better-copper-wire-shortcut-icon__/graphics/icons/shortcut-toolbar/mip/new-copper-wire-x26.png"}, -- 2 extra pixels for the caps
}

data.raw["gui-style"]["default"].shortcut_bar_button.padding = 2 -- was 8

local red_shortcut = data.raw["shortcut"]["give-red-wire"]
red_shortcut.icon = "__better-copper-wire-shortcut-icon__/graphics/icons/shortcut-toolbar/mip/new-red-wire-x56.png"
red_shortcut.icon_size = 56
red_shortcut.small_icon = "__better-copper-wire-shortcut-icon__/graphics/icons/shortcut-toolbar/mip/new-red-wire-x24.png"
red_shortcut.small_icon_size = 24

local green_shortcut = data.raw["shortcut"]["give-green-wire"]
green_shortcut.icon = "__better-copper-wire-shortcut-icon__/graphics/icons/shortcut-toolbar/mip/new-green-wire-x56.png"
green_shortcut.icon_size = 56
green_shortcut.small_icon = "__better-copper-wire-shortcut-icon__/graphics/icons/shortcut-toolbar/mip/new-green-wire-x24.png"
green_shortcut.small_icon_size = 24
