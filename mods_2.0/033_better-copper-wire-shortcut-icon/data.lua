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

data.raw["item"]["copper-wire"].icons = copper_shortcut.icons
