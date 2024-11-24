local shared = require("shared")

for _, type_and_name in ipairs({{type = "construction-robot", name = "construction-robot"}, {type = "logistic-robot", name = "logistic-robot"}}) do
  for i, multiplier in ipairs(shared.multipliers) do
    local prototype = table.deepcopy(data.raw[type_and_name.type][type_and_name.name])

    prototype.max_energy = string.format("1%sJ", multiplier)
    prototype.max_to_charge = 1

    prototype.name = string.format("%s-%s", prototype.name, prototype.max_energy)
    prototype.localised_name = {"", {"entity-name." .. type_and_name.name}, string.format(" [font=default-tiny-bold]%s[/font]", prototype.max_energy)}
    prototype.order = string.format("%s-multiplier-%s", type_and_name.name, string.format("%02d", i))

    local icons = {{icon = prototype.icon}}
    table.insert(icons, {
      icon = "__base__/graphics/icons/signal/signal_" .. "1" .. ".png",
      icon_size = 64,
      scale = 0.25,
      shift = {-8, -8}
    })
    table.insert(icons, {
      icon = "__base__/graphics/icons/signal/signal_" .. string.lower(multiplier) .. ".png",
      icon_size = 64,
      scale = 0.25,
      shift = { 8, -8}
    })
    prototype.icon = nil
    prototype.icons = icons

    -- another mod is currently overriding this, so set it back to the basemod default:
    prototype.energy_per_tick = "0.05kJ"
    prototype.energy_per_move = "5kJ"

    local item = table.deepcopy(data.raw["item"][type_and_name.name])
    item.name = string.format("%s-%s", prototype.name, prototype.max_energy)
    item.icons = prototype.icons
    item.place_result = prototype.name
    prototype.minable.result = item.name

    data:extend{prototype, item}
  end
end
