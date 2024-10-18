local sink = table.deepcopy(data.raw["linked-belt"]["linked-belt"])
local shop = table.deepcopy(data.raw["linked-container"]["linked-chest"])

local sink_item = table.deepcopy(data.raw["item"]["linked-belt"])
local shop_item = table.deepcopy(data.raw["item"]["linked-chest"])

sink_item.name = "awesome-sink"
sink_item.icon = "__awesome-sink__/graphics/icons/awesome-sink.png"
sink.name = sink_item.name
sink.icon = sink_item.icon

shop_item.name = "awesome-shop"
shop_item.icon = "__awesome-sink__/graphics/icons/awesome-shop.png"
shop.name = shop_item.name
shop.icon = shop_item.icon

sink_item.place_result = sink.name
shop_item.place_result = shop.name

sink.minable.result = sink_item.name
shop.minable.result = shop_item.name

for _, direction_thing in pairs(sink.structure) do
  if direction_thing.sheet.filename then
    direction_thing.sheet.filename = "__awesome-sink__/graphics/entity/awesome-sink.png"
  end
end
shop.picture.layers[1].filename = "__awesome-sink__/graphics/entity/awesome-shop.png"

-- too heavy for rocket
sink_item.weight = 10 * tons
shop_item.weight = 10 * tons

sink_item.stack_size = 1
shop_item.stack_size = 1

data:extend{
  sink, sink_item,
  shop, shop_item,
}
