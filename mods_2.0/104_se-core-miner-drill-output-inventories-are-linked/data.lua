local drill = data.raw["mining-drill"]["se-core-miner-drill"]
drill.vector_to_place_result = {0, 0}

data:extend({
  {
    type = "linked-container",
    name = "se-core-miner-drill-linked-container",
    inventory_size = 10,
    gui_mode = "none",
    collision_box = drill.collision_box,
    selection_box = drill.selection_box,
    collision_mask = {layers = {}},
    selection_priority = 51,
    flags = {
      "not-on-map",
      "hide-alt-info",
      "no-automated-item-insertion",
      "player-creation",
    },
    selectable_in_game = false,
    hidden = true,
  }
})
