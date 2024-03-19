local mod_prefix = 'fietff-'

local names_of_logistic_containers_with_request_slots = {}

for _, logistic_container in pairs(data.raw["logistic-container"]) do
  if logistic_container.logistic_mode == "requester" or logistic_container.logistic_mode == "buffer" then
    table.insert(names_of_logistic_containers_with_request_slots, logistic_container.name)
  end
end

for _, infinity_container in pairs(data.raw["infinity-container"]) do
  table.insert(names_of_logistic_containers_with_request_slots, infinity_container.name)

  -- infinity_container.gui_mode = 'none' -- non operable :|

  -- -- in case this breaks a custom description in your mod, please reach out and i'll try to incorporate it into the fallback ?
  -- infinity_container.localised_description = {"?", {"infinity-container.gui-mode-" .. (infinity_container.gui_mode or "all")}}
end

data.raw["container"][mod_prefix .. "container-1"].additional_pastable_entities = names_of_logistic_containers_with_request_slots
data.raw["container"][mod_prefix .. "container-2"].additional_pastable_entities = names_of_logistic_containers_with_request_slots
data.raw["container"][mod_prefix .. "container-3"].additional_pastable_entities = names_of_logistic_containers_with_request_slots

data:extend{
  {
    type = 'item-subgroup',
    name = mod_prefix .. 'fluid-port-in',

    group = 'other',
  },
  {
    type = 'item-subgroup',
    name = mod_prefix .. 'fluid-port-out',

    group = 'other',
  },
}

for _, fluid in pairs(data.raw['fluid']) do
  data:extend{
    {
      type = 'recipe',
      name = string.format(mod_prefix .. 'fluid-port-%s-in', fluid.name),
      localised_name = {"recipe-name.fietff-fluid-port-in", fluid.name},

      category = mod_prefix .. 'fluid-port',
      subgroup = mod_prefix .. 'fluid-port-in',
      icons = data.raw['item'][mod_prefix .. 'item-' .. 1].icons,

      ingredients = {
        {type = 'fluid', name = fluid.name, amount = 1},
      },
      results = {},
    },
    {
      type = 'recipe',
      name = string.format(mod_prefix .. 'fluid-port-%s-out', fluid.name),
      localised_name = {"recipe-name.fietff-fluid-port-out", fluid.name},

      category = mod_prefix .. 'fluid-port',
      subgroup = mod_prefix .. 'fluid-port-out',
      icons = data.raw['item'][mod_prefix .. 'item-' .. 2].icons,

      ingredients = {},
      results = {
        {type = 'fluid', name = fluid.name, amount = 1},
      },
    }
  }
end
