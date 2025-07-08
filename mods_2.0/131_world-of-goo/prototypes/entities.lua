local pipe_cap = {
  type = "simple-entity",
  name = mod_prefix .. "pipe-cap",

  icon = mod_directory .. "/graphics/entity/pipe-cap.png",
  icon_size = 100,

  picture = {
    north = {
      filename = mod_directory .. "/graphics/entity/pipe-cap.png",
      width = 100,
      height = 100,
      shift = {0, -0.55},
    },
    east = util.empty_sprite(),
    south = util.empty_sprite(),
    west = util.empty_sprite(),
  },

  selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
  -- collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
  collision_box = {{-7, -7}, {7, 7}},
  collision_mask = {layers = {water_tile = true}},

  map_color = {255, 255, 255, 128},
  autoplace = {
    order = "a[ruin]-a[vault]",
    probability_expression = "(min(fulgora_spots, (1 - fulgora_starting_vault_cone) / 2) < 0.015) * min(fulgora_vaults_and_starting_vault, 1 - fulgora_starting_mask)"
  }
}

data:extend{pipe_cap}
