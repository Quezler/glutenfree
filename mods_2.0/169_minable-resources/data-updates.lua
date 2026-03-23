local mod_data = {
  -- node_info = {},
  node_item_name_set = {},
  resource_to_node_map = {},
  -- item_ingredients_map = {},
}

data:extend{{
  type = "mod-data",
  name = "minable-resources",
  data = mod_data,
}}

data:extend{{
  type = "module-category",
  name = "resource",
}}

local function handle_resource(resource)
  local result = resource.minable.results and resource.minable.results[1] or {type = "item", name = resource.minable.result}
  if result.name == nil then return end
  if result.type ~= "item" then return end -- fluid yield behavior not yet defined

  local item = {
    type = "item-with-tags",
    name = resource.name .. "-node",
    localised_name = {"item-name.resource-node", resource.localised_name or {"entity-name." .. resource.name}},
    icons = {
      {icon = resource.icon, scale = 0.50},
      {icon = resource.icon, scale = 0.45},
      {icon = resource.icon, scale = 0.40},
      {icon = resource.icon, scale = 0.35},
    },
    order = resource.order,
    flags = {"not-stackable"},

    subgroup = "nodes",
    stack_size = 1,
  }

  local module = {
    type = "module",
    name = item.name .. "-module",
    localised_name = item.localised_name,
    icons = item.icons,
    order = resource.order,

    tier = 1,
    category = "resource",
    effect = {},
    spoil_ticks = 60,
    spoil_result = item.name,

    subgroup = "nodes",
    stack_size = 1,
    hidden_in_factoriopedia = true,
    factoriopedia_alternative = item.name,
  }

  data:extend{item, module}
  mod_data.node_item_name_set[item.name] = true
  mod_data.resource_to_node_map[resource.name] = item.name
  -- mod_data.item_ingredients_map[result.name] = item.name
end

for _, resource in pairs(data.raw["resource"]) do
  handle_resource(resource)
  -- local result = resource.minable.results and resource.minable.results[1] or resource.minable.result
  -- if result.type == "item" then

  -- end
  -- mod_data.node_info[resource.name] = {
  --   result = assert(resource.minable.results and resource.minable.results[1] or resource.minable.result)
  -- }
  -- log(resource.name .. serpent.line(resource.minable))
end
