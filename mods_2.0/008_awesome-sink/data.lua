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

shop.inventory_size = 48
shop.inventory_type = "normal"
shop.gui_mode = "none"
table.insert(shop.flags, "no-automated-item-insertion")

data:extend{
  sink, sink_item,
  shop, shop_item,
}

for _, prototype in ipairs({
  data.raw["decider-combinator"]["decider-combinator"],
  data.raw["arithmetic-combinator"]["arithmetic-combinator"],
}) do
  local awesome_combinator = table.deepcopy(prototype)
  awesome_combinator.name = "awesome-" .. awesome_combinator.name
  awesome_combinator.energy_source = {type = "void"}
  awesome_combinator.minable.result = nil
  awesome_combinator.hidden = true
  awesome_combinator.hidden_in_factoriopedia = true
  data:extend{awesome_combinator}
end

-- data.raw["container"]["wooden-chest"].picture.layers[1] = util.empty_sprite()

data:extend{{
  type = "recipe-category",
  name = "awesome-sink",
}}

local assembler = {
  type = "furnace",
  name = "awesome-sink-gui",

  icon = sink_item.icon,

  selection_box = sink.selection_box,
  collision_box = sink.collision_box,
  collision_mask = sink.collision_mask,

  flags = {"placeable-neutral", "placeable-player", "player-creation"},
  crafting_categories = {"awesome-sink"},

  graphics_set = util.empty_sprite(),

  module_slots = 2,
  allowed_effects = {"quality"},

  energy_usage = "1kW",
  energy_source = {type = "void"},
  crafting_speed = 1, -- todo: ask for an interface request that assembling machines can opt out of quality boosts

  selection_priority = 51,
  icon_draw_specification = {scale = 0},
  icons_positioning =
  {
    {inventory_index = defines.inventory.assembling_machine_modules, shift = {0, 0}, max_icon_rows = 1, max_icons_per_row = 2, scale = 0.45}
  },

  max_health = sink.max_health,
  source_inventory_size = 0,
  result_inventory_size = 0,
  vector_to_place_result = {0, -1}, -- without this the furnace doesn't want to rotate, though assembling machines will.

  placeable_by = {item = sink_item.name, count = 1},
  minable = sink.minable,
}

data:extend{assembler}
