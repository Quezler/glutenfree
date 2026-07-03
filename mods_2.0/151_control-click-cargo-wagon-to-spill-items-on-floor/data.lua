require("namespace")

data:extend({
  {
    type = "custom-input", key_sequence = "",
    name = mod_prefix .. "fast-entity-transfer",
    linked_game_control = "fast-entity-transfer",
  }
})

-- local entity = table.deepcopy(data.raw["cargo-landing-pad"]["cargo-landing-pad"])
-- entity.name = "other-cargo-landing-pad"
-- entity.collision_box = {{-3.49, -3.49}, {3.49, 3.49}}
-- data:extend{entity}
-- data.raw["cargo-landing-pad"]["cargo-landing-pad"].build_grid_size = 1
