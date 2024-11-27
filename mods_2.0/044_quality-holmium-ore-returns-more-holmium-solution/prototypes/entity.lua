return {
  new_holmium_chemical_plant = function(quality)
    local holmium_chemical_plant = table.deepcopy(data.raw["assembling-machine"]["chemical-plant"])
    -- holmium_chemical_plant.name = quality.name .. "-holmium-chemical-plant"
    holmium_chemical_plant.name = string.format("%sholmium-chemical-plant", quality.name ~= "normal" and quality.name .. "-" or "")
    holmium_chemical_plant.localised_name = {"entity-name.holmium-chemical-plant"}

    holmium_chemical_plant.icons = {
      {icon = "__quality-holmium-ore-returns-more-holmium-solution__/graphics/icons/holmium-chemical-plant.png"},
    }
    if quality.name ~= "normal" then table.insert(holmium_chemical_plant.icons, {icon = quality.icon, scale = 0.25, shift = {-8, 8}}) end

    holmium_chemical_plant.order = "[holmium-chemical-plant]-" .. quality.order

    holmium_chemical_plant.minable.result = "holmium-chemical-plant" -- for the item there is just one prototype

    holmium_chemical_plant.graphics_set.animation = make_4way_animation_from_spritesheet({layers =
    {
      {
        filename = "__quality-holmium-ore-returns-more-holmium-solution__/graphics/entity/holmium-chemical-plant/holmium-chemical-plant.png",
        width = 220,
        height = 292,
        frame_count = 24,
        line_length = 12,
        shift = util.by_pixel(0.5, -9),
        scale = 0.5
      },
      {
        filename = "__base__/graphics/entity/chemical-plant/chemical-plant-shadow.png",
        width = 312,
        height = 222,
        repeat_count = 24,
        shift = util.by_pixel(27, 6),
        draw_as_shadow = true,
        scale = 0.5
      }
    }})

    return holmium_chemical_plant
  end
}
