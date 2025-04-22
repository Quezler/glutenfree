local function sprite_with_shadow(name, config)
  config = config or {}

  local sprite = {
    type = "sprite",
    name = name,
    layers = {
      {
        filename = mod_directory .. "/graphics/entity/pipe-pillar/" .. name .. ".png",
        scale = 0.5,
        width = 704,
        height = 704,
      },
    }
  }

  if config.shadow ~= false then
    table.insert(sprite.layers, {
      filename = mod_directory .. "/graphics/entity/pipe-pillar/" .. name .. "-shadow.png",
      scale = 0.5,
      width = 704,
      height = 704,
      draw_as_shadow = true,
    })
  end

  return sprite
end

data:extend{
  sprite_with_shadow("pipe-pillar-elevated-horizontal-left", {shadow = false}),
  sprite_with_shadow("pipe-pillar-elevated-horizontal-right", {shadow = false}),
  sprite_with_shadow("pipe-pillar-elevated-horizontal-center"),
  sprite_with_shadow("pipe-pillar-elevated-horizontal-single"),
  sprite_with_shadow("pipe-pillar-elevated-vertical-top"),
  sprite_with_shadow("pipe-pillar-elevated-vertical-bottom"),
  sprite_with_shadow("pipe-pillar-elevated-vertical-center"),
  sprite_with_shadow("pipe-pillar-elevated-vertical-single"),
  sprite_with_shadow("pipe-pillar-occluder-tip", {shadow = false}),
}
