local landing_pad_entity = data.raw["cargo-landing-pad"]["cargo-landing-pad"]
local landing_pad_item = data.raw["item"]["cargo-landing-pad"]

-- local og_landing_pad_item = table.deepcopy(landing_pad_item)
-- og_landing_pad_item.name = "og-cargo-landing-pad"
-- og_landing_pad_item.hidden = true
-- og_landing_pad_item.localised_name = {"entity-name." .. landing_pad_entity.name}

landing_pad_item.localised_name = {"entity-name." .. landing_pad_entity.name}

landing_pad_item.icon = "__space-exploration-graphics__/graphics/icons/rocket-landing-pad.png"

local proxy_container = {
  type = "proxy-container",
  name = "cargo-landing-pad-proxy",
  -- localised_name = {"entity-name." .. landing_pad_entity.name},

  flags = {"player-creation", "not-on-map"},

  selection_priority = 51,
  selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
  collision_box = {{-4.4, -4.4}, {4.4, 4.4}},
  collision_mask = landing_pad_entity.collision_mask,

  picture = {
    filename = "__space-exploration-graphics-5__/graphics/entity/rocket-landing-pad/rocket-landing-pad.png",
    height = 768,
    width = 704,
    shift = {0, -0.5},
    scale = 0.5
  },

  circuit_connector =
  {
    points = {
      shadow =
        {
          red = {-3.5, 2.7},
          green = {-3.6, 2.6},
        },
      wire =
        {
          red = {-3.5, 2.7},
          green = {-3.6, 2.6},
        }
    }
  },
  circuit_wire_max_distance = 12.5
}

landing_pad_entity.collision_mask = {layers = {}}
landing_pad_item.place_result = proxy_container.name
proxy_container.minable = landing_pad_entity.minable
-- landing_pad_entity.placeable_by = {item = og_landing_pad_item.name, count = 1}

table.insert(landing_pad_entity.flags, "not-blueprintable")
table.insert(landing_pad_entity.flags, "not-deconstructable")
table.insert(landing_pad_entity.flags, "no-automated-item-removal")
table.insert(landing_pad_entity.flags, "no-automated-item-insertion")

landing_pad_entity.graphics_set = nil
landing_pad_entity.robot_animation = nil
landing_pad_entity.cargo_station_parameters.giga_hatch_definitions = nil

data:extend{proxy_container}

landing_pad_entity.draw_stateless_visualisations_in_ghost = true
landing_pad_entity.stateless_visualisation = {
  render_layer = "lower-object",
  animation = {
    filename = "__space-exploration-graphics-5__/graphics/entity/rocket-landing-pad/rocket-landing-pad.png",
    height = 768,
    width = 704,
    shift = {0, -0.25},
    scale = 0.4
  }
}

for _, property in ipairs({
  "max_health",
  "resistances",
  "open_sound",
  "close_sound",
}) do
  proxy_container[property] = landing_pad_entity[property]
end
