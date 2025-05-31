local scale = 0.75

local function scale_layer(layer)
  layer.scale = (layer.scale or 1) * scale

  if layer.shift then
    layer.shift = {layer.shift[1] * scale, layer.shift[2] * scale}
  end
end

return function(prototype)
  prototype.selection_box = {
    {prototype.selection_box[1][1] * scale, prototype.selection_box[1][2] * scale},
    {prototype.selection_box[2][1] * scale, prototype.selection_box[2][2] * scale}
  }

  prototype.collision_box = {
    {prototype.collision_box[1][1] * scale, prototype.collision_box[1][2] * scale},
    {prototype.collision_box[2][1] * scale, prototype.collision_box[2][2] * scale}
  }

  -- prototype.logistics_radius = prototype.logistics_radius * scale
  -- prototype.logistics_connection_distance = prototype.logistics_connection_distance * scale
  -- prototype.construction_radius = prototype.construction_radius * scale

  for _, layer in ipairs(prototype.base.layers) do
    scale_layer(layer)
  end

  scale_layer(prototype.base_patch)
  scale_layer(prototype.base_animation)
  scale_layer(prototype.door_animation_up)
  scale_layer(prototype.door_animation_down)

  if prototype.frozen_patch then
    scale_layer(prototype.frozen_patch)
  end

  prototype.max_health = prototype.max_health * scale
end
