local mod_prefix = "glutenfree-se-spaceship-juicebox-"

local logistic_modes = {"active-provider", "storage"}
for _, logistic_mode in ipairs(logistic_modes) do
  local entity = {}
  entity.type = "logistic-container"
  entity.name = mod_prefix .. logistic_mode

  -- LogisticContainer
  entity.logistic_mode = logistic_mode
  if logistic_mode == "storage" then
    entity.max_logistic_slots = 0
  end
  entity.render_not_in_network_icon = false

  -- Container
  entity.inventory_size = 0 -- for the time being the inventory_size_override is not checked by spaceship integrity
  entity.inventory_type = "normal"
  entity.picture = {
    filename = "__glutenfree-se-spaceship-juicebox__/graphics/entities/juicebox.png",
    width = 15,
    height = 23,
    scale = 0.5,
  }

  -- Entity
  entity.flags = {"placeable-off-grid", "no-automated-item-removal", "no-automated-item-insertion"}
  entity.collision_mask = {layers = {}}
  entity.selection_box = {{-0.24, -0.24}, {0.24, 0.24}}
  entity.selection_priority = (data.raw["accumulator"]["se-spaceship-console"].selection_priority or 50) + 1
  entity.localised_name = {"entity-name." .. mod_prefix .. "*"}
  entity.icon_draw_specification = {scale = 0.25, scale_for_many = 0.5}

  -- Compatibility
  entity.se_allow_in_space = true

  -- icon for the container integrity breakdown
  entity.icons = data.raw["item"]["se-spaceship-console"].icons
  table.insert(entity.icons, {
    icon = "__glutenfree-se-spaceship-juicebox__/graphics/entities/spaceship-console-juicebox.png",
    icon_size = 64
  })

  data:extend({entity})
end
