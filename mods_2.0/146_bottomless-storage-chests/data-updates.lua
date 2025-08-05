local tint = {0.4, 0.4, 0.4}

local co

local function create_bottomless_version(prototype)
  local name = "bottomless-" .. prototype.name

  local entity = table.deepcopy(prototype)
  entity.name = name
  entity.inventory_size = 1
  entity.inventory_type = "with_custom_stack_size"
  entity.inventory_properties = {stack_size_min = 1000000000}
  entity.minable.result = name
  entity.minable.mining_time = 1
  entity.quality_affects_inventory_size = false
  table.insert(entity.flags, "no-automated-item-insertion")
  table.insert(entity.flags, "no-automated-item-removal")
  -- entity.animation.layers[1].tint = {tint[1]*1.5, tint[2]*1.5, tint[3]*1.5}
  -- for _, layer in ipairs(entity.animation.layers) do
  --   layer.tint = {tint[1]*1.5, tint[2]*1.5, tint[3]*1.5}
  -- end
  -- if mods["aai-containers"] then
  --   entity.animation.layers[1].tint = {tint[1]*1.5, tint[2]*1.5, tint[3]*1.5}
  -- else
  --   entity.animation.layers[1].tint = {tint[1]*1.5, tint[2]*1.5, tint[3]*1.5}
  -- end
  for _, layer in ipairs(entity.animation.layers) do
    layer.tint = layer.tint or {1, 1, 1}
    if layer.tint.r then layer.tint = {layer.tint.r, layer.tint.g, layer.tint.b} end
    layer.tint = {layer.tint[1]*tint[1], layer.tint[2]*tint[2], layer.tint[3]*tint[3]}
  end
  -- entity.animation =
  -- {
  --   layers =
  --   {
  --     {
  --       filename = "__base__/graphics/entity/logistic-chest/storage-chest.png",
  --       priority = "extra-high",
  --       width = 66,
  --       height = 74,
  --       frame_count = 7,
  --       shift = util.by_pixel(0, -2),
  --       scale = 0.5,
  --       tint = {tint[1]*1.5, tint[2]*1.5, tint[3]*1.5}
  --     },
  --     {
  --       filename = "__base__/graphics/entity/logistic-chest/logistic-chest-shadow.png",
  --       priority = "extra-high",
  --       width = 112,
  --       height = 46,
  --       repeat_count = 7,
  --       shift = util.by_pixel(12, 4.5),
  --       draw_as_shadow = true,
  --       scale = 0.5
  --     }
  --   }
  -- }

  if mods["space-exploration"] then
    entity.collision_mask = table.deepcopy(data.raw["utility-constants"]["default"].default_collision_masks["logistic-container"])
    entity.collision_mask.layers["moving_tile"] = true
  end

  local item = table.deepcopy(data.raw["item"][prototype.name])
  item.name = name
  item.place_result = name
  item.order = string.format("%s-a[%s]", item.order, name)
  item.weight = kg * 100

  if item.icon then
    item.icons = {{icon = item.icon, tint = tint}}
    item.icon = nil
  else
  --   -- if mods["aai-containers"] then
  --   --   item.icons[1].tint = tint -- mask layer
  --   -- else
  --   --   item.icons[1].tint = tint
  --   -- end
    for i, icon in ipairs(item.icons) do
      if not (mods["aai-container"] and i == 1) then
        icon.tint = icon.tint or {1, 1, 1}
        if icon.tint.r then icon.tint = {icon.tint.r, icon.tint.g, icon.tint.b} end
        icon.tint = {icon.tint[1]*tint[1], icon.tint[2]*tint[2], icon.tint[3]*tint[3]}
      end
    end
  end
  -- item.icons = {{icon = "__base__/graphics/icons/storage-chest.png", tint = tint}}

  -- right of the acrolink chest
  if mods["space-exploration"] then
    item.subgroup = "container-2"
    item.order = "z-m"
  end

  local recipe =
  {
    type = "recipe",
    name = name,
    enabled = false,
    ingredients =
    {
      {type = "item", name = prototype.name, amount = 1},
      {type = "item", name = "burner-mining-drill", amount = 1},
      {type = "item", name = "coal", amount = 50}
    },
    energy_required = 25, -- roughly the time 1 coal lasts in a burner drill
    results = {{type="item", name=name, amount=1}}
  }

  -- insert the bottomless chest to the right of anywhere it is current unlocked
  for _, technology in pairs(data.raw["technology"]) do
    for i, effect in ipairs(technology.effects or {}) do
      if effect.type == "unlock-recipe" and effect.recipe == prototype.name then
        table.insert(technology.effects, i + 1, {
          type = "unlock-recipe", recipe = recipe.name,
        })
      end
    end
  end

  data:extend{entity, item, recipe}
end

create_bottomless_version(data.raw["logistic-container"]["storage-chest"])


