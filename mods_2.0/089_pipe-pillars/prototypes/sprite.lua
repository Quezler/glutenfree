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
        -- flags = {"no-crop", "not-compressed", "linear-mip-level", "linear-minification", "linear-magnification"},
      },
    }
  }

  if config.shadow ~= false then
    table.insert(sprite.layers, {
      filename = mod_directory .. "/graphics/entity/pipe-pillar/" .. (config.shadow and config.shadow or (name .. "-shadow")) .. ".png",
      scale = 0.5,
      width = 704,
      height = 704,
      draw_as_shadow = true,
    })
  end

  return sprite
end

local horizontal_shadow = {shadow = "pipe-pillar-elevated-horizontal-center-shadow"}
local vertical_shadow = {shadow = "pipe-pillar-elevated-vertical-center-shadow"}

data:extend{
  sprite_with_shadow("pipe-pillar-elevated-horizontal-left", horizontal_shadow),
  sprite_with_shadow("pipe-pillar-elevated-horizontal-right", horizontal_shadow),
  sprite_with_shadow("pipe-pillar-elevated-horizontal-center", horizontal_shadow),
  sprite_with_shadow("pipe-pillar-elevated-horizontal-single", horizontal_shadow),
  sprite_with_shadow("pipe-pillar-elevated-vertical-top", vertical_shadow),
  sprite_with_shadow("pipe-pillar-elevated-vertical-bottom", vertical_shadow),
  sprite_with_shadow("pipe-pillar-elevated-vertical-center", vertical_shadow),
  sprite_with_shadow("pipe-pillar-elevated-vertical-single", vertical_shadow),
  sprite_with_shadow("pipe-pillar-occluder-top", {shadow = false}),
  sprite_with_shadow("pipe-pillar-occluder-bottom", {shadow = false}),
}
