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
    name = mod_prefix .. 'storage-tanks',

    group = 'other',
  }
}

if data.raw['fluid']['se-decompressing-steam'] then
  data.raw['fluid']['se-decompressing-steam'].fietff_storage_tank_ignore = true
end

for _, fluid in pairs(data.raw['fluid']) do
  if fluid.hidden then goto continue end
  if fluid.fietff_storage_tank_ignore then goto continue end

  local icons1 = table.deepcopy(data.raw['item'][mod_prefix .. 'item-' .. 1].icons)
  local icons2 = fluid.icons and table.deepcopy(fluid.icons) or {{icon = fluid.icon, icon_size = fluid.icon_size, icon_mipmaps = fluid.icon_mipmaps}}

  assert(fluid.localised_name == nil, 'this mod does not yet support handling prelocalized fluids.')

  data:extend{
    {
      type = 'storage-tank',
      name = string.format(mod_prefix .. 'storage-tank-%s', fluid.name),
      localised_name = {"entity-name.fietff-storage-tank-fluidname", {"fluid-name." .. fluid.name}},
      localised_description = {"entity-description.fietff-storage-tank-fluidname"},

      subgroup = mod_prefix .. 'storage-tanks',
      icons = util.combine_icons(icons1, icons2, {scale = 0.5}),

      collision_mask = {},
      collision_box = {{-0.3, -0.3}, {0.3, 0.3}},
      selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
      selection_priority = 51,

      fluid_box = {
        production_type = "input-output",
        pipe_picture = util.empty_sprite(),
        pipe_covers = pipecoverspictures(),
        base_area = 1,
        base_level = -1,
        filter = fluid.name,
        pipe_connections = {{ type="input-output", position = {0, -1} }},
      },

      window_bounding_box = {{0, 0}, {0 , 0}},

      pictures = {
        picture = util.empty_sprite(),
        window_background = util.empty_sprite(),
        fluid_background = util.empty_sprite(),
        flow_sprite = util.empty_sprite(),
        gas_flow = util.empty_sprite(),
      },

      flow_length_in_ticks = 1,
      max_health = 100,

      show_fluid_icon = false, -- >= 1.1.105
    }
  }

  ::continue::
end
