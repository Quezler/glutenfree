local mod_data = {
  for_find_entities_filtered = {},
  loader_to_spaceship_loader = {},
  spaceship_loader_to_loader = {},
}

data:extend{{
  type = "mod-data",
  name = "se-space-loaders-can-reach-behind-spaceship-walls",
  data = mod_data,
}}

local function create_spaceship_loader(prototype)
  local loader = table.deepcopy(prototype)

  loader.name = loader.name .. "-spaceship"
  loader.localised_name = nil
  loader.container_distance = loader.container_distance + 1
  loader.placeable_by = {item = prototype.name, count = 1}

  data:extend{loader}

  table.insert(mod_data.for_find_entities_filtered, prototype.name)
  table.insert(mod_data.for_find_entities_filtered, loader.name)

  mod_data.loader_to_spaceship_loader[prototype.name] = loader.name
  mod_data.spaceship_loader_to_loader[loader.name] = prototype.name
end

create_spaceship_loader(data.raw["loader-1x1"]["kr-se-loader"])
create_spaceship_loader(data.raw["loader-1x1"]["kr-se-deep-space-loader-black"])
