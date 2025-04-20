local function sprite_with_shadow(name)
  return {
    type = "sprite",
    name = name,
    layers = {
      {
        filename = mod_directory .. "/graphics/entity/pipe-pillar/" .. name .. ".png",
        scale = 0.5,
        width = 704,
        height = 704,
      },
      {
        filename = mod_directory .. "/graphics/entity/pipe-pillar/" .. name .. "-shadow.png",
        scale = 0.5,
        width = 704,
        height = 704,
        draw_as_shadow = true,
      },
    }
  }
end

data:extend{
  sprite_with_shadow("pipe-pillar-elevated-horizontal-left"),
  sprite_with_shadow("pipe-pillar-elevated-horizontal-right"),
  sprite_with_shadow("pipe-pillar-elevated-horizontal-center"),
  sprite_with_shadow("pipe-pillar-elevated-vertical-top"),
  sprite_with_shadow("pipe-pillar-elevated-vertical-bottom"),
  sprite_with_shadow("pipe-pillar-elevated-vertical-center"),
  {
    type = "sprite",
    name = "pipe-pillar-elevated-pipe-cover-occluder",
    layers = {
      {
        filename = mod_directory .. "/graphics/entity/pipe-pillar/pipe-pillar-elevated-pipe-cover-down.png",
        scale = 0.5,
        width = 704,
        height = 704,
      },
      {
        filename = mod_directory .. "/graphics/entity/pipe-pillar/pipe-pillar-elevated-pipe-cover-left.png",
        scale = 0.5,
        width = 704,
        height = 704,
      },
      {
        filename = mod_directory .. "/graphics/entity/pipe-pillar/pipe-pillar-elevated-pipe-cover-right.png",
        scale = 0.5,
        width = 704,
        height = 704,
      },
    },
  },
}
