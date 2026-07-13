local function sprite_with_shadow(config, variation, shadow)
  local sprite = {
    type = "sprite",
    name = config.name .. variation,
    layers = {
      {
        filename = config.graphics .. variation .. ".png",
        scale = 0.5,
        width = 704,
        height = 704,
      },
      {
        filename = config.graphics .. shadow .. ".png",
        scale = 0.5,
        width = 704,
        height = 704,
        draw_as_shadow = true,
      },
    }
  }

  return sprite
end

elevated_pipes.new_sprites = function (config)
local horizontal_shadow = "-horizontal-center-shadow"
local vertical_shadow = "-vertical-center-shadow"

data:extend{
  sprite_with_shadow(config, "-horizontal-left"  , horizontal_shadow),
  sprite_with_shadow(config, "-horizontal-right" , horizontal_shadow),
  sprite_with_shadow(config, "-horizontal-center", horizontal_shadow),
  sprite_with_shadow(config, "-horizontal-single", horizontal_shadow),
  sprite_with_shadow(config, "-vertical-top"     , vertical_shadow),
  sprite_with_shadow(config, "-vertical-bottom"  , vertical_shadow),
  sprite_with_shadow(config, "-vertical-center"  , vertical_shadow),
  sprite_with_shadow(config, "-vertical-single"  , vertical_shadow),
}
end
