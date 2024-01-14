local shared = require('shared')

local mod_prefix = 'fietff-'
local Factory = {}

function Factory.get_constant_combinator_parameters(clipboard)
  local parameters = {}
  local i = 1

  for _, building in ipairs(clipboard.buildings) do
    table.insert(parameters, {
      signal = {type = "item", name = building.name},
      count = -building.amount,
      index = i,
    })
    i = i + 1
  end

  for _, ingredient in ipairs(clipboard.ingredients) do
    table.insert(parameters, {
      signal = {type = "item", name = ingredient.name},
      count = -math.ceil(ingredient.amount),
      index = i,
    })
    i = i + 1
  end

  return parameters
end

function Factory.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination

  if event.player_index == nil then
    game.print(string.format('The %s should only be built by players.', entity.name))
    entity.destroy()
    return
  end

  local player = game.get_player(event.player_index)
  local clipboard = global.clipboards[player.index]
  if not clipboard then
    entity.destroy()
    return player.create_local_flying_text{
      text = "Grab a new one from the factory planner gui.",
      create_at_cursor = true,
    }
  else
    global.clipboards[player.index] = nil -- mark clipboard as consumed
  end

  local combinator = entity.surface.create_entity{
    name = mod_prefix .. 'constant-combinator',
    force = entity.force,
    position = {entity.position.x, entity.position.y},
  }
  combinator.destructible = false
  combinator.get_control_behavior().parameters = Factory.get_constant_combinator_parameters(clipboard) -- will crash if a factory needs over 40 slots (excl. output)
  combinator.connect_neighbour({
    target_entity = entity,
    wire = defines.wire_type.red,
  })
  combinator.connect_neighbour({
    target_entity = entity,
    wire = defines.wire_type.green,
  })

  local assembler = entity.surface.create_entity{
    name = mod_prefix .. 'assembling-machine-1',
    force = entity.force,
    position = {entity.position.x, entity.position.y},
  }
  assembler.destructible = false

  local eei = entity.surface.create_entity{
    name = mod_prefix .. 'electric-energy-interface-1',
    force = entity.force,
    position = {entity.position.x, entity.position.y + shared.electric_energy_interface_1_y_offset},
  }
  eei.destructible = false

  -- eei.power_usage = clipboard.watts / 60
  eei.electric_buffer_size = math.max(1, clipboard.watts) -- buffer for 1 second

  local struct = {
    unit_number = entity.unit_number,
    container = entity,

    assembler = assembler,
    eei = eei,

    clipboard = clipboard,

    input_buffer = {},
    output_buffer = {},

    output_slots_required = table_size(clipboard.products) + table_size(clipboard.byproducts),
    rendered = {},
  }

  for _, ingredient in ipairs(clipboard.ingredients) do
    struct.input_buffer[ingredient.name] = 0
  end

  for _, product in ipairs(clipboard.products) do
    struct.output_buffer[product.name] = 0
  end

  for _, byproduct in ipairs(clipboard.byproducts) do
    struct.output_buffer[byproduct.name] = 0
  end

  struct.rendered.factory_name = rendering.draw_text{
    text = clipboard.factory_name,
    color = {1, 1, 1},
    surface = entity.surface,
    target = entity,
    target_offset = {0, -3.75},
    alignment = "center",
    use_rich_text = true,
  }

  struct.rendered.factory_description = rendering.draw_text{
    text = clipboard.factory_description,
    color = {1, 1, 1},
    surface = entity.surface,
    target = entity,
    target_offset = {0, -3.00},
    alignment = "center",
    use_rich_text = true,
    scale = 0.5,
  }

  struct.rendered.factory_message = rendering.draw_text{
    text = 'owo',
    color = {1, 1, 1},
    surface = entity.surface,
    target = entity,
    target_offset = {0, 0.75},
    alignment = "center",
    use_rich_text = true,
    scale = 1,
  }

  global.structs[entity.unit_number] = struct
  Factory.tick_struct(struct)

  global.deathrattles[script.register_on_entity_destroyed(entity)] = {combinator, assembler, eei}
end

function Factory.tick_struct(struct)
  if struct.container.valid == false then
    global.structs[struct.unit_number] = nil
    return
  end

  local inventory = struct.container.get_inventory(defines.inventory.chest)
  local inventory_contents = inventory.get_contents()

  local proxy_requests = {}

  -- game.print(serpent.line(struct.clipboard.buildings))
  for _, building in ipairs(struct.clipboard.buildings) do
    local missing = building.amount - (inventory_contents[building.name] or 0)
    if missing > 0 then
      proxy_requests[building.name] = missing
    end
  end

  if table_size(proxy_requests) > 0 then
    local surface = struct.container.surface
    local proxy = surface.find_entity('item-request-proxy', struct.container.position)
    if proxy then
      proxy.item_requests = proxy_requests
    else
      struct.proxy = surface.create_entity{
        name = 'item-request-proxy',
        force = struct.container.force,
        position = struct.container.position,
        modules = proxy_requests,
        target = struct.container,
      }
    end
    struct.eei.power_usage = 0
    rendering.set_text(struct.rendered.factory_message, 'missing buildings/modules')
    return -- wait for the factory to be constructed
  elseif struct.proxy then
    struct.eei.power_usage = struct.clipboard.watts / 60
    struct.proxy.destroy()
    struct.proxy = nil
  end

  -- game.print('craft cycle')

  local purse = struct.assembler.get_inventory(defines.inventory.assembling_machine_output)
  local purse_coin_count = purse.get_item_count(mod_prefix .. 'coin')
  if 60 > purse_coin_count then
    return rendering.set_text(struct.rendered.factory_message, string.format('charging up seconds (%s/60)', purse_coin_count))
    -- return -- power ("rent") costs not paid in full yet
  end
  struct.eei.power_usage = 0 -- disable power usage until after a successful craft cycle

  -- can we afford the next craft cycle?
  for _, ingredient in ipairs(struct.clipboard.ingredients) do
    local available = (inventory_contents[ingredient.name] or 0) + struct.input_buffer[ingredient.name]
    if ingredient.amount > available then return rendering.set_text(struct.rendered.factory_message, "not enough ingredients") end
  end

  -- is there room for the next craft cycle?
  if struct.output_slots_required > inventory.count_empty_stacks() then return rendering.set_text(struct.rendered.factory_message, "not enough output space") end

  local item_statistics = struct.container.force.item_production_statistics

  for _, ingredient in ipairs(struct.clipboard.ingredients) do
    -- refill the buffer, which will now have enough for a cycle
    local top_up_with = math.ceil(ingredient.amount - struct.input_buffer[ingredient.name])
    item_statistics.on_flow(ingredient.name, -top_up_with)
    struct.input_buffer[ingredient.name] = struct.input_buffer[ingredient.name] + inventory.remove({name = ingredient.name, count = top_up_with})

    -- and now we subtract the ingredient costs from the buffer
    struct.input_buffer[ingredient.name] = struct.input_buffer[ingredient.name] - ingredient.amount
  end

  do -- calculate and give the output
    for _, product in ipairs(struct.clipboard.products) do
      struct.output_buffer[product.name] = struct.output_buffer[product.name] + product.amount
    end
  
    for _, byproduct in ipairs(struct.clipboard.byproducts) do
      struct.output_buffer[byproduct.name] = struct.output_buffer[byproduct.name] + byproduct.amount
    end
  
    for item_name, item_count in pairs(struct.output_buffer) do
      local payout = math.floor(item_count)
      if payout > 0 then
        item_statistics.on_flow(item_name, payout)
        struct.output_buffer[item_name] = struct.output_buffer[item_name] - inventory.insert({name = item_name, count = item_count})
      end
    end
  end

  -- now that we've outputed results, use power again
  purse.clear() -- claim the 60 coins in there
  struct.eei.power_usage = struct.clipboard.watts / 60
  rendering.set_text(struct.rendered.factory_message, "produced output")
end

return Factory
