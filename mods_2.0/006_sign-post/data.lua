local display_panel = data.raw["display-panel"]["display-panel"]

local sign_post = table.deepcopy(display_panel)
local sign_post_item = table.deepcopy(data.raw["item"]["display-panel"])

sign_post.name = "sign-post"
sign_post_item.name = sign_post.name

sign_post.minable.result = sign_post_item.name
sign_post_item.place_result = sign_post.name

sign_post.icon = "__sign-post__/graphics/icons/sign-post.png"
sign_post_item.icon = "__sign-post__/graphics/icons/sign-post.png"

sign_post.selection_box = {{-0.5, -0.75}, {0.5, 0.5}}
sign_post.sprites =
{
  layers =
  {
    {
      filename = "__sign-post__/graphics/entity/sign-post.png",
      priority = "extra-high",
      width = 150,
      height = 150,
      shift = util.by_pixel(-1.5, 0),
      scale = 0.5,
    },
    {
      filename = "__sign-post__/graphics/entity/sign-post.png",
      priority = "extra-high",
      width = 150,
      x = 150,
      height = 150,
      shift = util.by_pixel(0, 0),
      scale = 0.5,
      draw_as_shadow = true,
    }
  }
}
sign_post.text_shift = {0, -1.0}
sign_post.icon_draw_specification = {shift = {0, -0.365}, scale = 0.4}

data:extend{sign_post, sign_post_item}

data:extend{{
  type = "recipe",
  name = "sign-post",
  ingredients = {{type = "item", name = "wood", amount = 1}},
  results = {{type="item", name="sign-post", amount=1}},
  enabled = true,
}}

sign_post.circuit_connector = nil
sign_post.circuit_wire_max_distance = 0

sign_post.fast_replaceable_group = "display-panel"
assert(display_panel.fast_replaceable_group == nil) -- hi fellow modder, do reach out if this is inconvenient for you!
display_panel.fast_replaceable_group = "display-panel"
