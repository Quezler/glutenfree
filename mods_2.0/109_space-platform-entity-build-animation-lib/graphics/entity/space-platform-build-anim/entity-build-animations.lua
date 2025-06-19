local frame_count = 32
local scale = 0.5
local animation_speed = 0.5

local animations =
{
  back_left =
  {
    top =
    {
      layers =
      {
        util.sprite_load(mod_directory .. "/graphics/entity/space-platform-build-anim/back-L-top",{
          frame_count = frame_count,
          scale = scale,
          animation_speed = animation_speed
        })
      }
    },
    body =
    {
      layers =
      {
        util.sprite_load(mod_directory .. "/graphics/entity/space-platform-build-anim/back-L",{
          frame_count = frame_count,
          scale = scale,
          animation_speed = animation_speed
        }),
        util.sprite_load(mod_directory .. "/graphics/entity/space-platform-build-anim/back-L-shadow",{
          draw_as_shadow = true,
          frame_count = frame_count,
          scale = scale,
          animation_speed = animation_speed
        })
      }
    }
  },
  back_right =
  {
    top =
    {
      layers =
      {
        util.sprite_load(mod_directory .. "/graphics/entity/space-platform-build-anim/back-R-top",{
          frame_count = frame_count,
          scale = scale,
          animation_speed = animation_speed
        })
      }
    },
    body =
    {
      layers =
      {
        util.sprite_load(mod_directory .. "/graphics/entity/space-platform-build-anim/back-R",{
          frame_count = frame_count,
          scale = scale,
          animation_speed = animation_speed
        }),
        util.sprite_load(mod_directory .. "/graphics/entity/space-platform-build-anim/back-R-shadow",{
          draw_as_shadow = true,
          frame_count = frame_count,
          scale = scale,
          animation_speed = animation_speed
        })
      }
    }
  },
  front_left =
  {
    top =
    {
      layers =
      {
        util.sprite_load(mod_directory .. "/graphics/entity/space-platform-build-anim/front-L-top",{
          frame_count = frame_count,
          scale = scale,
          animation_speed = animation_speed
        })
      }
    },
    body =
    {
      layers =
      {
        util.sprite_load(mod_directory .. "/graphics/entity/space-platform-build-anim/front-L",{
          frame_count = frame_count,
          scale = scale,
          animation_speed = animation_speed
        }),
        util.sprite_load(mod_directory .. "/graphics/entity/space-platform-build-anim/front-L-shadow",{
          draw_as_shadow = true,
          frame_count = frame_count,
          scale = scale,
          animation_speed = animation_speed
        })
      }
    }
  },
  front_right =
  {
    top =
    {
      layers =
      {
        util.sprite_load(mod_directory .. "/graphics/entity/space-platform-build-anim/front-R-top",{
          frame_count = frame_count,
          scale = scale,
          animation_speed = animation_speed
        })
      }
    },
    body =
    {
      layers =
      {
        util.sprite_load(mod_directory .. "/graphics/entity/space-platform-build-anim/front-R",{
          frame_count = frame_count,
          scale = scale,
          animation_speed = animation_speed
        }),
        util.sprite_load(mod_directory .. "/graphics/entity/space-platform-build-anim/front-R-shadow",{
          draw_as_shadow = true,
          frame_count = frame_count,
          scale = scale,
          animation_speed = animation_speed
        })
      }
    }
  }
}

return animations;
