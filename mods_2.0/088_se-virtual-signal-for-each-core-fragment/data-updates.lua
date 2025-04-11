local function starts_with(str, start)
  return str:sub(1, #start) == start
end

data:extend{{
  type = "item-subgroup",
  name = "se-core-fragment-signals",
  group = "signals",
  order = "e"
}}

local signal_background = {
  icon =  "__base__/graphics/icons/signal/signal_blue.png",
  icon_size = 64, icon_mipmaps = 4,
}

for _, item in pairs(data.raw["item"]) do
  if starts_with(item.name, "se-core-fragment-") then
    local signal = {
      type = "virtual-signal",
      name = item.name .. "-virtual-signal",
      icons = item.icons,
      localised_name = {"", "Signal", " ", item.localised_name or {"item-name." .. item.name}},
      subgroup = "se-core-fragment-signals",
      order = item.order,
    }

    for _, icon in ipairs(signal.icons) do
      icon.scale = (icon.scale or 1) * 0.7
    end
    signal.icons = {signal.icons[#signal.icons]}
    signal.icons[1].tint = {0.7, 0.7, 0.7, 0.7}
    table.insert(signal.icons, 1, signal_background)

    data:extend{signal}
  end
end
