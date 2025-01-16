local item_sounds = require("__base__.prototypes.item_sounds")

local technology = data.raw["technology"]["fast-inserter"]
technology.icon = "__greedy-inserter__/graphics/technology/fast-inserter.png"
table.insert(technology.effects, {type = "unlock-recipe", recipe = "greedy-inserter"})

local entity = table.deepcopy(data.raw["inserter"]["fast-inserter"])
entity.name = "greedy-inserter"
entity.icon = "__greedy-inserter__/graphics/icons/greedy-inserter.png"
entity.filter_count = 1 -- allowing multiple items is just asking for trouble

entity.hand_base_picture =
{
  filename = "__greedy-inserter__/graphics/entity/greedy-inserter/greedy-inserter-hand-base.png",
  priority = "extra-high",
  width = 32,
  height = 136,
  scale = 0.25
}
entity.hand_closed_picture =
{
  filename = "__greedy-inserter__/graphics/entity/greedy-inserter/greedy-inserter-hand-closed.png",
  priority = "extra-high",
  width = 72,
  height = 164,
  scale = 0.25
}
entity.hand_open_picture =
{
  filename = "__greedy-inserter__/graphics/entity/greedy-inserter/greedy-inserter-hand-open.png",
  priority = "extra-high",
  width = 72,
  height = 164,
  scale = 0.25
}
entity.platform_picture =
{
  sheet =
  {
    filename = "__greedy-inserter__/graphics/entity/greedy-inserter/greedy-inserter-platform.png",
    priority = "extra-high",
    width = 105,
    height = 79,
    shift = util.by_pixel(1.5, 7.5-1),
    scale = 0.5
  }
}

-- entity.energy_source = {
--   type = "burner",
--   fuel_inventory_size = 1,
-- }

local item = {
  type = "item",
  name = "greedy-inserter",
  icon = "__greedy-inserter__/graphics/icons/greedy-inserter.png",
  subgroup = "inserter",
  color_hint = { text = "G" },
  order = "e[greedy-inserter]",
  inventory_move_sound = item_sounds.inserter_inventory_move,
  pick_sound = item_sounds.inserter_inventory_pickup,
  drop_sound = item_sounds.inserter_inventory_move,
  stack_size = 50
}

item.place_result = entity.name
entity.minable.result = item.name

local recipe = {
  type = "recipe",
  name = "greedy-inserter",
  enabled = false,
  ingredients =
  {
    {type = "item", name = "fast-inserter", amount = 1},
    {type = "item", name = "electronic-circuit", amount = 4},
  },
  results = {{type="item", name=item.name, amount=1}}
}

local corpse = {
  type = "corpse",
  name = "greedy-inserter-remnants",
  icon = "__greedy-inserter__/graphics/icons/greedy-inserter.png",
  hidden_in_factoriopedia = true,
  flags = {"placeable-neutral", "not-on-map"},
  subgroup = "inserter-remnants",
  order = "a-e-a",
  selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
  tile_width = 1,
  tile_height = 1,
  selectable_in_game = false,
  time_before_removed = 60 * 60 * 15, -- 15 minutes
  expires = false,
  final_render_layer = "remnants",
  remove_on_tile_placement = false,
  animation = make_rotated_animation_variations_from_sheet (4,
  {
    filename = "__greedy-inserter__/graphics/entity/greedy-inserter/remnants/greedy-inserter-remnants.png",
    line_length = 1,
    width = 134,
    height = 94,
    direction_count = 1,
    shift = util.by_pixel(3.5, -2),
    scale = 0.5
  })
}

corpse.localised_name = {"remnant-name", {"entity-name."..corpse.name:gsub("%-remnants", "")}}
entity.corpse = corpse.name

data:extend({entity, item, recipe, corpse})
