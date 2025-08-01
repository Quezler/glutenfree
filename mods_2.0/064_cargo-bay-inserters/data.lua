require("shared")

local proxy_tint = {0.8, 0.1, 0.3}

local platform_cargo_bay = {
  type = "proxy-container",
  name = mod_prefix .. "platform-cargo-bay-proxy",

  icons = {
    {icon = "__space-age__/graphics/icons/space-platform-hub.png", tint = proxy_tint}
  },

  -- matches the boxes of the cargo bay
  collision_box = {{-1.9, -1.9}, {1.9, 1.9}},
  selection_box = {{-2.0, -2.0}, {2.0, 2.0}},
  collision_mask = {layers = {}},
  build_grid_size = 2,

  flags = {"player-creation", "not-on-map"},
  draw_inventory_content = false,
  selectable_in_game = false,
  selection_priority = 49,
  hidden = true,
}

local planet_cargo_bay = table.deepcopy(platform_cargo_bay)
planet_cargo_bay.name = mod_prefix .. "planet-cargo-bay-proxy"
planet_cargo_bay.icons[1].icon = "__base__/graphics/icons/cargo-landing-pad.png"

data:extend{platform_cargo_bay, planet_cargo_bay}
