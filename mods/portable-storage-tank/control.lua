local util = require('util')

local tank_capacity = {}
local function get_tank_capacity(entity_name)
  if not tank_capacity[entity_name] then
    local fluidbox_prototype = game.entity_prototypes[entity_name].fluidbox_prototypes[1]
    tank_capacity[entity_name] = fluidbox_prototype.base_area * fluidbox_prototype.height * 100
  end
  return tank_capacity[entity_name]
end

script.on_event(defines.events.on_player_mined_entity, function(event)
  game.print(serpent.block(event.buffer.get_contents()))

  local itemstack, slot = event.buffer.find_item_stack('storage-tank')
  assert(itemstack and itemstack.is_item_with_tags)

  local fluids = {}

  -- for _, fluidbox in ipairs(event.entity.fluidbox) do
  --   game.print()
  -- end

  for i = 1, #event.entity.fluidbox do
    local fluid = event.entity.fluidbox[i]
    fluids[i] = fluid
  end

  itemstack.tags = {fluids = fluids}
  itemstack.custom_description = '[fluid=se-liquid-rocket-fuel] 1234k at 10 c'
  itemstack.custom_description = {'', '[fluid=se-liquid-rocket-fuel] ', '[font=default-bold]', {'fluid-name.se-liquid-rocket-fuel'}, '[/font]', '\n', get_tank_capacity('storage-tank')}
  itemstack.custom_description = {'', '[fluid=se-liquid-rocket-fuel] ', '[font=default-bold]', {'fluid-name.se-liquid-rocket-fuel'}, '[/font]', '\n', '[font=default-semibold]', math.ceil(fluids[1].amount), '[/font]', ' at ', '[font=default-semibold]', math.ceil(fluids[1].temperature), '[/font]', '°C'}
  itemstack.custom_description = {'', '[fluid=se-liquid-rocket-fuel] ', '[color=255,230,192][font=default-bold]', {'fluid-name.se-liquid-rocket-fuel'}, '[/font][/color]', '\n', '[font=default-semibold]', math.ceil(fluids[1].amount), '[/font]', ' at ', '[font=default-semibold]', math.ceil(fluids[1].temperature), '[/font]', '°C'}
  itemstack.custom_description = {'', '[fluid=se-liquid-rocket-fuel] ', '[color=255,230,192][font=default-bold]', {'fluid-name.se-liquid-rocket-fuel'}, '[/font][/color]', '\n', '[font=default-semibold]', util.format_number(fluids[1].amount, true), '[/font]', ' at ', '[font=default-semibold]', math.ceil(fluids[1].temperature), '[/font]', '°C'}
  itemstack.health = math.random()

  game.print(serpent.block(fluids))
end)
