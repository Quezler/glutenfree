polluting_names = {}
alt_polluting_names = {}

for type, names in pairs(data.raw) do
  for name, prototype in pairs(names) do
    if prototype.energy_source and prototype.energy_source.type == "electric" and prototype.energy_source.emissions_per_minute then

      if prototype.name ~= "kr-air-purifier" then
      -- only show the purifier himself in alt mode
        table.insert(polluting_names, prototype.name)
      end

      table.insert(alt_polluting_names, prototype.name)
    end
  end
end

log("polluting_names:\n" .. serpent.block(polluting_names))

data:extend({
  {
    type = "shortcut",
    name = "pollution-tool",

    action = "spawn-item",
    item_to_spawn = "pollution-tool",

    style = "default",
    icon = "__Krastorio2Assets__/icons/items/pollution-filter.png",
    small_icon = "__Krastorio2Assets__/icons/items/pollution-filter.png",
  },
  {
    type = "selection-tool",
    name = "pollution-tool",
    icon = "__Krastorio2Assets__/icons/items/pollution-filter.png",
    icon_size = 64,
    icon_mipmaps = 4,
    flags = {"not-stackable", "spawnable", "only-in-cursor"},
    stack_size = 1,

    select = {
      border_color = {r = 0.9, g = 0.9, b = 0.9},
      mode = {"same-force", "deconstruct"},
      cursor_box_type = "train-visualization",
      entity_filters = polluting_names,
    },

    alt_select = {
      border_color = {r = 0.9, g = 0.9, b = 0.9},
      mode = {"same-force", "deconstruct"},
      cursor_box_type = "train-visualization",
      entity_filters = alt_polluting_names,
    },

    hidden = true,
  },
})
