local shared = require('shared')

local mod_prefix = 'fietff-'
local Factory = {}

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

  eei.power_usage = clipboard.watts / 60
  eei.electric_buffer_size = math.max(1, clipboard.watts) -- buffer for 1 second

  rendering.draw_text{
    text = clipboard.factory_name,
    color = {1, 1, 1},
    surface = entity.surface,
    target = entity,
    target_offset = {0, -3.75},
    alignment = "center",
    use_rich_text = true,
  }

  local io_string = ""

  for _, product in ipairs(clipboard.products) do
    io_string = io_string .. string.format('[%s=%s]', product.type, product.name)
  end
  io_string = io_string .. ' - '

  if #clipboard.byproducts > 0 then
    for _, byproduct in ipairs(clipboard.byproducts) do
      io_string = io_string .. string.format('[%s=%s]', byproduct.type, byproduct.name)
    end
    io_string = io_string .. ' - '
  end

  for _, ingredient in ipairs(clipboard.ingredients) do
    io_string = io_string .. string.format('[%s=%s]', ingredient.type, ingredient.name)
  end

  rendering.draw_text{
    text = io_string,
    color = {1, 1, 1},
    surface = entity.surface,
    target = entity,
    target_offset = {0, -3.00},
    alignment = "center",
    use_rich_text = true,
    scale = 0.5,
  }

  global.structs[entity.unit_number] = {
    unit_number = entity.unit_number,
    container = entity,

    assembler = assembler,
    eei = eei,

    clipboard = clipboard,
  }

  Factory.tick_struct(global.structs[entity.unit_number])

  global.deathrattles[script.register_on_entity_destroyed(entity)] = {assembler, eei}
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
    return -- wait for the factory to be constructed
  elseif struct.proxy then
    game.print('construction complete.')
    struct.proxy.destroy()
    struct.proxy = nil
  end

end

return Factory
