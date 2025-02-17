require("shared")

local entity = table.deepcopy(data.raw["space-platform-hub"]["space-platform-hub"])
entity.name = "creative-" .. entity.name

local item = table.deepcopy(data.raw["space-platform-starter-pack"]["space-platform-starter-pack"])
item.name = "creative-" .. item.name
item.order = "c[creative-space-platform-starter-pack]"
item.trigger[1].action_delivery.source_effects[1].entity_name = entity.name

data:extend{entity, item}

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

local sprite = require("__space-age__/graphics/entity/cargo-hubs/hubs/platform-hub-3")
sprite.type = "sprite"
sprite.name = mod_prefix .. "platform-hub-3"
sprite.filename = "__space-age__/graphics/entity/cargo-hubs/hubs/platform-hub-3.png"
sprite.tint = {0.5, 0.5, 1}
sprite.scale = 0.5
data:extend{sprite}
