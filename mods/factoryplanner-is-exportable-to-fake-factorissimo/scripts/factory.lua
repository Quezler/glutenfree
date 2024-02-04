local shared = require('shared')
local util = require('__core__.lualib.util')

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

function Factory.slots_required_for(ingredients)
  local slots = 0
  for _, ingredient in ipairs(ingredients) do
    assert(ingredient.type == "item")
    local item_prototype = game.item_prototypes[ingredient.name]
    slots = slots + math.ceil(ingredient.amount / item_prototype.stack_size)
  end
  return slots
end

function Factory.inflate_buffers(struct)
  for _, ingredient in ipairs(struct.clipboard.ingredients) do
    struct.input_buffer[ingredient.name] = struct.input_buffer[ingredient.name] or 0
  end

  for _, product in ipairs(struct.clipboard.products) do
    struct.output_buffer[product.name] = struct.output_buffer[product.name] or 0
  end

  for _, byproduct in ipairs(struct.clipboard.byproducts) do
    struct.output_buffer[byproduct.name] = struct.output_buffer[byproduct.name] or 0
  end
end

local container_name_to_tier = {
  [mod_prefix .. 'container-1'] = 1,
  [mod_prefix .. 'container-2'] = 2,
  [mod_prefix .. 'container-3'] = 3,
}

function Factory.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination

  local tier = container_name_to_tier[entity.name]

  local clipboard = nil
  local player = nil

  if entity.type == "entity-ghost" then
    if entity.tags and entity.tags.source_struct_unit_number then
      local source_struct = global.structs[entity.tags.source_struct_unit_number]
      if source_struct then
        clipboard = table.deepcopy(source_struct.clipboard)
        local _, revived, _ = entity.revive{}
        if revived == nil then return end
        entity = revived
        goto clipboard_copied_from_source_struct
      end
    end
    return
  end

  if event.robot then
    local cells = event.robot.logistic_network.cells
    if #cells == 1 and cells[1].owner.type == "character" then
      event.player_index = cells[1].owner.player.index
    end
  end

  if event.player_index == nil then
    game.print(string.format('The %s should only be built by players.', entity.name))
    entity.destroy()
    return
  end

  player = game.get_player(event.player_index)
  clipboard = global.clipboards[player.index]
  if not clipboard then
    entity.destroy()
    return player.create_local_flying_text{
      text = "Grab a new one from the factory planner gui.",
      create_at_cursor = true,
    }
  else
    global.clipboards[player.index] = nil -- mark clipboard as consumed
  end
  
  ::clipboard_copied_from_source_struct::

  local combinator = entity.surface.create_entity{
    name = mod_prefix .. 'constant-combinator-1',
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
    name = mod_prefix .. 'electric-energy-interface-' .. tier,
    force = entity.force,
    position = {entity.position.x, entity.position.y + shared[string.format('electric_energy_interface_%d_y_offset', tier)]},
  }
  eei.destructible = false

  eei.electric_buffer_size = math.max(1, clipboard.watts) -- buffer for 1 second
  eei.power_usage = clipboard.watts / 60

  local struct = {
    unit_number = entity.unit_number,
    version = 2,

    container = entity,
    combinator = combinator,
    assembler = assembler,
    eei = eei,

    clipboard = clipboard,

    input_buffer = {},
    output_buffer = {},

    output_slots_required = Factory.slots_required_for(clipboard.products) + Factory.slots_required_for(clipboard.byproducts),
    rendered = {},
  }

  Factory.inflate_buffers(struct)

  struct.rendered.factory_name = rendering.draw_text{
    text = clipboard.factory_name,
    color = {1, 1, 1},
    surface = entity.surface,
    target = entity,
    target_offset = {0, -3.75},
    alignment = "center",
    use_rich_text = true,
  }

  local factory_description_prefix = ''
  if #clipboard.products == 1 then
    factory_description_prefix = clipboard.products[1].amount .. 'x '
  end

  struct.rendered.factory_description = rendering.draw_text{
    text = factory_description_prefix .. clipboard.factory_description,
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

  if (struct.version or 0) == 0 then
    if #struct.clipboard.products == 1 then
      rendering.set_text(struct.rendered.factory_description, struct.clipboard.products[1].amount .. 'x ' .. struct.clipboard.factory_description)
    end
    struct.version = 1
  end

  if struct.version == 1 then
    struct.combinator = struct.container.surface.find_entity(mod_prefix .. 'constant-combinator-1', struct.container.position)
    struct.version = 2
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
    rendering.set_text(struct.rendered.factory_message, '[img=utility/status_not_working] missing buildings/modules')
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
    return rendering.set_text(struct.rendered.factory_message, string.format('[img=utility/status_working] working (%s/60)', purse_coin_count))
  end
  struct.eei.power_usage = 0 -- disable power usage until after a successful craft cycle

  -- can we afford the next craft cycle?
  for _, ingredient in ipairs(struct.clipboard.ingredients) do
    local available = (inventory_contents[ingredient.name] or 0) + struct.input_buffer[ingredient.name]
    if ingredient.amount > available then return rendering.set_text(struct.rendered.factory_message, "[img=utility/status_not_working] not enough ingredients") end
  end

  for _, product in ipairs(struct.clipboard.products) do
    if inventory_contents[product.name] then
      return rendering.set_text(struct.rendered.factory_message, "[img=utility/status_yellow] output full")
    end
  end

  -- is there room for the next craft cycle? (products & byproducts stacking and/or merging existing partial stacks is not taken into account)
  local empty_slots = inventory.count_empty_stacks()
  if struct.output_slots_required > empty_slots then return rendering.set_text(struct.rendered.factory_message, string.format("[img=utility/status_not_working] not enough output space (%d>%d)", struct.output_slots_required, empty_slots)) end

  local item_statistics = struct.container.force.item_production_statistics

  for _, ingredient in ipairs(struct.clipboard.ingredients) do
    -- refill the buffer, which will now have enough for a cycle
    local top_up_with = math.ceil(ingredient.amount - struct.input_buffer[ingredient.name])
    if top_up_with > 0 then
      item_statistics.on_flow(ingredient.name, -top_up_with)
      struct.input_buffer[ingredient.name] = struct.input_buffer[ingredient.name] + inventory.remove({name = ingredient.name, count = top_up_with})
    end

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

  struct.container.surface.pollute(struct.container.position, struct.clipboard.pollution)

  -- now that we've outputed results, use power again
  purse.clear() -- claim the 60 coins in there
  struct.eei.power_usage = struct.clipboard.watts / 60
  rendering.set_text(struct.rendered.factory_message, "[img=utility/status_working] produced output")
end

function Factory.on_entity_settings_pasted(event)
  -- game.print(event.source.name .. ' -> ' .. event.destination.name)
  if event.source.name == mod_prefix .. "container-1" and event.destination.type == "logistic-container" then
    for i = 1, event.destination.request_slot_count, 1 do
      event.destination.clear_request_slot(i)
    end

    local struct = global.structs[event.source.unit_number]
    -- if struct == nil then return end
    -- if struct.container.valid == false then return end

    for i, ingredient in ipairs(struct.clipboard.ingredients) do
      event.destination.set_request_slot({name = ingredient.name, count = math.ceil(ingredient.amount)}, i)
    end
  end

  if event.source.name == mod_prefix .. "container-1" and event.destination.name == mod_prefix .. "container-1" then
    local source_struct = global.structs[event.source.unit_number]
    local destination_struct = global.structs[event.destination.unit_number]

    destination_struct.clipboard = table.deepcopy(source_struct.clipboard)
    destination_struct.combinator.get_control_behavior().parameters = source_struct.combinator.get_control_behavior().parameters

    Factory.inflate_buffers(destination_struct) -- we do not erase the old buffers
    destination_struct.output_slots_required = table.deepcopy(source_struct.output_slots_required)

    rendering.set_text(destination_struct.rendered.factory_name, rendering.get_text(source_struct.rendered.factory_name))
    rendering.set_text(destination_struct.rendered.factory_description, rendering.get_text(source_struct.rendered.factory_description))

    destination_struct.eei.electric_buffer_size = math.max(1, destination_struct.clipboard.watts)
    destination_struct.eei.power_usage = 0

    destination_struct.assembler.get_inventory(defines.inventory.assembling_machine_output).clear()

    Factory.tick_struct(destination_struct)
  end
end

function Factory.on_player_setup_blueprint(event)
  local player = game.get_player(event.player_index)
  if player.connected == false then return end

  local blueprint = nil

  if player.blueprint_to_setup and player.blueprint_to_setup.valid_for_read then blueprint = player.blueprint_to_setup
  elseif player.cursor_stack.valid_for_read and player.cursor_stack.is_blueprint then blueprint = player.cursor_stack end

  if blueprint == nil then return end
  if blueprint.is_blueprint_setup() == false then return end

  local mapping = event.mapping.get()
  local blueprint_entities = blueprint.get_blueprint_entities()
  if blueprint_entities then
    for _, blueprint_entity in ipairs(blueprint_entities) do
      if blueprint_entity.name == mod_prefix .. "container-1" then
        local entity = mapping[blueprint_entity.entity_number]
        if entity then
          local struct = global.structs[entity.unit_number]
          if struct then
            blueprint.set_blueprint_entity_tags(blueprint_entity.entity_number, {
              source_struct_unit_number = struct.unit_number,
            })
          end
        end
      end
    end
  end
end

commands.add_command(mod_prefix .. "struct", nil, function(command)
  local player = game.get_player(command.player_index)
  if player.selected == nil then return end
  if player.selected.unit_number == nil then return end

  local struct = global.structs[player.selected.unit_number]
  if struct == nil then return end

  player.print(serpent.line( struct ))
end)

return Factory
