require("shared")

local space_platform_hub = data.raw["space-platform-hub"]["space-platform-hub"]

for _, sprite in ipairs(space_platform_hub.graphics_set.picture) do
  if sprite.render_layer == "above-inserters" then
    sprite.render_layer = "item-in-inserter-hand"
  end
end

data:extend({
  {
    type = "custom-input", key_sequence = "",
    name = mod_prefix .. "cycle-quality-up",
    linked_game_control = "cycle-quality-up",
    include_selected_prototype = true,
  }
})

data:extend({
  {
    type = "custom-input", key_sequence = "",
    name = mod_prefix .. "cycle-quality-down",
    linked_game_control = "cycle-quality-down",
    include_selected_prototype = true,
  }
})

local tint = {0.5, 0.5, 1}

data:extend{util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hubs/platform-hub-3",
{
  type = "sprite",
  name = mod_prefix .. "platform-hub-3",
  scale = 0.5,
  shift = {0, -1},
  tint = tint,
})}

data:extend{util.sprite_load("__space-age__/graphics/entity/cargo-hubs/hatches/platform-upper-hatch-occluder",
{
  type = "sprite",
  name = mod_prefix .. "platform-upper-hatch-occluder",
  scale = 0.5,
  shift = {0, -1},
  tint = tint,
})}
