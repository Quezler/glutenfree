local util = require('util')

local booster_tanks_filter = {
  {filter = 'name', name = 'se-spaceship-rocket-booster-tank'},
  {filter = 'name', name = 'se-spaceship-ion-booster-tank'},
  {filter = 'name', name = 'se-spaceship-antimatter-booster-tank'},
}

local tank_capacity = {}
local function get_tank_capacity(entity_name)
  if not tank_capacity[entity_name] then
    local fluidbox_prototype = game.entity_prototypes[entity_name].fluidbox_prototypes[1]
    tank_capacity[entity_name] = fluidbox_prototype.base_area * fluidbox_prototype.height * 100
  end
  return tank_capacity[entity_name]
end

script.on_event(defines.events.on_player_mined_entity, function(event)
  local itemstack, slot = event.buffer.find_item_stack(event.entity.name)
  assert(itemstack and itemstack.is_item_with_tags)

  local fluid = event.entity.fluidbox[1]
  if fluid == nil then return end -- tank already empty or managed to push fluids to neighbours

  itemstack.set_tag('__se-portable-booster-tank__', {
    id = global.next_id,
    fluid_name = fluid.name,
    fluid_amount = fluid.amount,
    fluid_temperature = fluid.temperature,
  })

  fluid_color = game.fluid_prototypes[fluid.name].flow_color

  local blocks = 17 -- matches the width the box already gets expanded to due to the 'Space Exploration - portable booster tank' prototype history (on my screen)
  local fullness = fluid.amount / get_tank_capacity(event.entity.name) -- 0-1
  local full_blocks = math.max(1, math.floor(blocks * fullness))
  local empty_blocks = blocks - full_blocks

  itemstack.custom_description = {'',
  string.format('[fluid=%s] ', fluid.name), '[color=255,230,192][font=default-bold]', {'fluid-name.se-liquid-rocket-fuel'}, '[/font][/color]',
  '\n',
  string.format('[color=%f,%f,%f]', fluid_color.r, fluid_color.g, fluid_color.b),
  string.rep('█', full_blocks),
  '[/color]',
  '[color=gray]', string.rep('█', empty_blocks), '[/color]',
  '\n',
  util.format_number(fluid.amount, true), ' at ', {'format-degrees-c-compact', math.ceil(fluid.temperature)}}

  global.next_id = global.next_id + 1

end, booster_tanks_filter)

script.on_init(function(event)
 global.next_id = 1 -- to make sure booster tanks are unable to stack
end)
