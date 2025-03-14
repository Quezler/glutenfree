local pump      = table.deepcopy(data.raw["pump"]["pump"])
local pump_item = table.deepcopy(data.raw["item"]["pump"])

pump.name = "pump-with-adjustable-flow-rate"
pump_item.name = pump.name

pump.minable.result = pump_item.name
pump_item.place_result = pump.name

local pump_recipe = {
  type = "recipe",
  name = pump_item.name,
  energy_required = 2,
  enabled = false,
  ingredients =
  {
    {type = "item", name = "pump", amount = 1},
    {type = "item", name = "arithmetic-combinator", amount = 1},
  },
  results = {{type="item", name=pump_item.name, amount=1}}
}

local technology = data.raw["technology"]["fluid-handling"]
for i, effect in ipairs(technology.effects) do
  if effect.type == "unlock-recipe" and effect.recipe == "pump" then
    table.insert(technology.effects, i + 1, {
      type = "unlock-recipe",
      recipe = pump_recipe.name,
    })
    break
  end
end

data:extend{pump, pump_item, pump_recipe, pump_recipe}

local icons = {
  {icon = "__base__/graphics/icons/pump.png"},
  {icon = "__core__/graphics/icons/technology/effect-constant/effect-constant-speed.png", scale = -0.5},
}

pump.icon = nil
pump.icons = icons

pump_item.icon = nil
pump_item.icons = icons

local pump_fluid = {
  type = "fluid",
  name = "pump-with-adjustable-flow-rate",
  icon = data.raw["virtual-signal"]["signal-F"].icon,

  default_temperature = -1,
  max_temperature = 1200,

  base_color = {r=146, g=098, b=053},
  flow_color = {r=146, g=098, b=053},

  auto_barrel = false,
  hidden = true
}

pump.energy_source = {
  type = "fluid",
  fluid_box = {
    volume = 100,
    pipe_connections = {},
    filter = pump_fluid.name,
  }
}

data:extend{pump_fluid}

data:extend{{
  type = "planet",
  name = "pump-with-adjustable-flow-rate",
  icons = icons,

  distance = 0,
  orientation = 0,

  hidden = true,
}}
