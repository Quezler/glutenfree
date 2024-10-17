local sign_post = data.raw["display-panel"]["display-panel"]
local sign_post_item = data.raw["item"]["display-panel"]

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
      scale = 0.5
    },
    {
      filename = "__sign-post__/graphics/entity/sign-post.png",
      priority = "extra-high",
      width = 150,
      x = 150,
      height = 150,
      shift = util.by_pixel(0, 0),
      scale = 0.5,
      draw_as_shadow = true
    }
  }
}
sign_post.text_shift = {0, -1.0}
sign_post.icon_draw_specification = {shift = {0, -0.35}, scale = 0.4}
table.insert(sign_post.flags, "not-rotatable")

data:extend{{
  type = "recipe-category",
  name = "handcrafting",
}}

table.insert(data.raw["character"]["character"].crafting_categories, "handcrafting")

data:extend{{
  type = "recipe",
  name = "wooden-sign-post",
  category = "handcrafting",
  ingredients = {{type="item", name="wood", amount=1}},
  results = {{type="item", name="display-panel", amount=1}},
  enabled = true,
}}

local smaller_universal_connector_template = table.deepcopy(universal_connector_template)
-- for k, v in pairs(smaller_universal_connector_template) do
--   if v["scale"] then
--     v["scale"] = v["scale"] * 0.5
--   end
-- end

circuit_connector_definitions["sign-post"] = circuit_connector_definitions.create_vector
(
  smaller_universal_connector_template,
  {
    { variation = 24, main_offset = util.by_pixel(-15.0, -16.5), shadow_offset = util.by_pixel(-15.0, -16.5), show_shadow = false },
    { variation = 24, main_offset = util.by_pixel(0, 0), shadow_offset = util.by_pixel(0, 0), show_shadow = false },
    { variation = 24, main_offset = util.by_pixel(0, 0), shadow_offset = util.by_pixel(0, 0), show_shadow = false },
    { variation = 24, main_offset = util.by_pixel(0, 0), shadow_offset = util.by_pixel(0, 0), show_shadow = false },
  }
)

sign_post.circuit_connector = circuit_connector_definitions["sign-post"]
