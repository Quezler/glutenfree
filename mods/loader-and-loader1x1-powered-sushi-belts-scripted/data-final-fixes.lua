local function in_array(array, value)
  for _, v in ipairs(array) do
    if v == value then return true end
  end
end

local function handle_container_prototype(prototype)
  prototype.flags = prototype.flags or {}

  if not in_array(prototype.flags, 'player-creation') then return end
  if     in_array(prototype.flags, 'hidden'         ) then return end
  
  log(prototype.name .. ' ' .. prototype.inventory_size)

  local name = 'sushi-container-' .. prototype.inventory_size
  if data.raw['container'][name] then return end

  data:extend({
    {
      type = 'container',
      name = name,
      inventory_size = prototype.inventory_size,
      enable_inventory_bar = false,
      collision_box = {{-0.25, -0.25}, {0.25, 0.25}},
      selection_box = {{-0.25, -0.25}, {0.25, 0.25}},
      collision_mask = {},
      selection_priority = (prototype.selection_priority or 50) + 1,
      -- picture = data.raw['linked-container']['linked-chest'].picture,
      picture = util.empty_sprite(),
      minable = {mining_time = 0.2},
      flags = {
        'player-creation',
        'placeable-off-grid',
        'not-on-map',
        'hide-alt-info',
        'no-automated-item-insertion',
      },
      icons = {
        {icon = "__base__/graphics/icons/fish.png", icon_size = 64, icon_mipmaps = 4},
        {icon = "__base__/graphics/icons/steel-axe.png", icon_size = 64, icon_mipmaps = 4},
      },
      localised_name = {"entity-name.sushi-container", prototype.inventory_size},
    }
  })
end

for _, prototype in pairs(data.raw['container']) do
  handle_container_prototype(prototype)
end

for _, prototype in pairs(data.raw['logistic-container']) do
  handle_container_prototype(prototype)
end

for _, prototype in pairs(data.raw['infinity-container']) do
  handle_container_prototype(prototype)
end
