-- i'd say i'm allowed to require postprocess since i want that description, and that mod generates it :)
-- (or at least it was the original plan to swap the cursor item with pipette, but then settled for this)

local function handle(name)
  local pole = data.raw['electric-pole'][name]
  local port = data.raw['roboport'][name .. '-roboport']

  local times = port.construction_radius / pole.supply_area_distance
  local layers = {}

  for w = 1, times do
    for h = 1, times do
      table.insert(layers, {
        filename = "__core__/graphics/visualization-construction-radius.png",
        height = 8,
        priority = "extra-high-no-scale",
        width = 8,
        shift = {(-1 + (w - times/2) * 2) / 8, (-1 + (h - times/2) * 2) / 8},
        blend_mode = "additive-soft", -- looks the best out of all the blend modes
      })
    end
  end

  if port.logistics_radius then
    assert(pole.supply_area_distance >= port.logistics_radius) -- hardcoded assumption that the logistic area is smaller than the power coverage
    table.insert(layers, {
      filename = "__core__/graphics/visualization-logistic-radius.png",
      height = 8,
      priority = "extra-high-no-scale",
      width = 8,
      scale = port.logistics_radius / pole.supply_area_distance,
      blend_mode = "additive-soft", -- looks the best out of all the blend modes
    })
  end

  table.insert(layers, {
    filename = "__base__/graphics/entity/small-electric-pole/electric-pole-radius-visualization.png",
    height = 8,
    priority = "extra-high-no-scale",
    width = 8,
  })

  pole.radius_visualisation_picture = {layers = layers}
end

handle('se-pylon-construction')
handle('se-pylon-construction-radar')
