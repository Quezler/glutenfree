local heat_pipe_item = data.raw["item"]["heat-pipe"]

local yellow_underground_belt = table.deepcopy(data.raw["underground-belt"]["underground-belt"])

local yellow_uhp = {
  type = "pipe-to-ground",
  name = "underground-heat-pipe",
  icons = {
    {draw_background = false, icon = "__core__/graphics/empty.png"},
    {draw_background = false, icon = heat_pipe_item.icon, scale = 0.3, shift = {-4, 0}},
    {draw_background = true,  icon = yellow_underground_belt.icon, scale = 0.4}
  },
  fluid_box = {
    volume = 1,
    pipe_connections =
    {
      {
        connection_type = "underground",
        direction = defines.direction.south,
        position = {0, 0},
        max_underground_distance = yellow_underground_belt.max_distance,
        connection_category = "underground-heat-pipe",
      }
    },
    hide_connection_info = true
  },
  collision_box = {{-0.3, -0.3}, {0.3, 0.3}},
  selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
}

local yellow_uhp_item = {
  type = "item",
  name = "underground-heat-pipe",
  icons = yellow_uhp.icons,
  subgroup = "energy",
  color_hint = { text = "1" },
  order = "f[nuclear-energy]-b[underground-heat-pipe]",
  inventory_move_sound = yellow_underground_belt.inventory_move_sound,
  pick_sound = yellow_underground_belt.pick_sound,
  drop_sound = yellow_underground_belt.drop_sound,
  place_result = yellow_uhp.name,
  stack_size = 50
}

local yellow_uhp_recipe = {
  type = "recipe",
  name = yellow_uhp_item.name,
  enabled = false,
  energy_required = 1,
  ingredients =
  {
    {type = "item", name = "heat-pipe", amount = yellow_underground_belt.max_distance},
    {type = "item", name = "underground-belt", amount = 2}
  },
  results = {{type="item", name=yellow_uhp_item.name, amount=2}}
}

local technology = data.raw["technology"]["nuclear-power"]
for i, effect in ipairs(technology.effects) do
  if effect.type == "unlock-recipe" and effect.recipe == "heat-pipe" then
    table.insert(technology.effects, i + 1, {
      type = "unlock-recipe",
      recipe = yellow_uhp_recipe.name,
    })
    break
  end
end

data:extend{yellow_uhp, yellow_uhp_item, yellow_uhp_recipe}
