local Util = require('__space-exploration-scripts__.util')
local Meteor = require('__space-exploration-scripts__.meteor')
--
local Handler = {}

function Handler.on_init(event)
  global.v1_structs = {}
  global.v1_unit_numbers = {}

  global.alert_targets = {}
  global.alert_targets_emptied = false
  global.alert_targets_per_tick = 1

  global.missing_items = {} -- holds missing items for all forces, though the code will only shoot if the forces match
  global.trash_unrequested_queue = {}

  Handler.regenerate_item_request_proxy_whitelist()
end

function Handler.on_configuration_changed(event)
  global.structs = nil
  global.deck = nil
  global.pile = nil
  global.handled_alerts = nil
  global.deathrattles = nil
  global.children_to_kill = nil
  global.rich_text_name_for_destination_surface = nil
  --
  global.v1_structs = global.v1_structs or {}
  global.v1_unit_numbers = global.v1_unit_numbers or {}

  global.alert_targets = global.alert_targets or {}
  global.alert_targets_emptied = global.alert_targets_emptied or false
  global.alert_targets_per_tick = global.alert_targets_per_tick or 1

  global.missing_items = global.missing_items or {}
  global.trash_unrequested_queue = global.trash_unrequested_queue or {}

  Handler.regenerate_item_request_proxy_whitelist()
end

local entity_name_bypasses_proxy_whitelist = {
  ['fietff-container-1'] = true,
  ['glutenfree-equipment-train-stop-template-container'] = true,
}
function Handler.regenerate_item_request_proxy_whitelist()
  global.item_request_proxy_whitelist = {}
  local module_prototypes = game.get_filtered_item_prototypes({{filter = "type", type = "module"}})
  for module_name, module_prototype in pairs(module_prototypes) do
    global.item_request_proxy_whitelist[module_name] = true
  end
end

function Handler.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination

  local v1_struct = {
    unit_number = entity.unit_number,
    entity = entity,
    barrel = 0,
  }

  global.v1_structs[entity.unit_number] = v1_struct
  table.insert(global.v1_unit_numbers, v1_struct.unit_number)

  Handler.update_logistic_requests(global.missing_items, v1_struct)
end

function Handler.shoot(v1_struct)
  v1_struct.barrel = v1_struct.barrel % 4 + 1
  v1_struct.entity.surface.create_entity{
    name = Meteor.name_meteor_point_defence_beam,
    position = Util.vectors_add(v1_struct.entity.position, Meteor.name_meteor_point_defence_beam_offsets[v1_struct.barrel]),
    target = Util.vectors_add(v1_struct.entity.position, {x = 0, y = -Meteor.meteor_swarm_altitude})
  }
end

-- determine what this construction alert desires
function Handler.items_to_place_this(alert_target)
  if alert_target.name == "entity-ghost" or alert_target.name == "tile-ghost" then
    return alert_target.ghost_prototype.items_to_place_this
  elseif alert_target.name == "item-request-proxy" then
    local items_to_place_this = {}
    for name, count in pairs(alert_target.item_requests) do
      if global.item_request_proxy_whitelist[name] or entity_name_bypasses_proxy_whitelist[alert_target.proxy_target.name] then
        table.insert(items_to_place_this, {name = name, count = count})
      end
    end
    return items_to_place_this
  elseif alert_target.get_upgrade_target() then
    return alert_target.get_upgrade_target().items_to_place_this
  end
end

function Handler.shuffle_array_in_place(t)
  for i = #t, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
  end
end

function Handler.handle_construction_alert(alert_target)
  local items_to_place_this = Handler.items_to_place_this(alert_target)
  if not items_to_place_this then return end -- upgrade canceled?

  local networks = alert_target.surface.find_logistic_networks_by_construction_area(alert_target.position, alert_target.force)
  if #networks == 0 then goto undeliverable end

  Handler.shuffle_array_in_place(global.v1_unit_numbers)

  for _, itemstack in ipairs(items_to_place_this) do
    for index, unit_number in ipairs(global.v1_unit_numbers) do
      local v1_struct = global.v1_structs[unit_number]
      if not v1_struct.entity.valid then
        global.v1_structs[unit_number] = nil
        table.remove(global.v1_unit_numbers, index)
        break
      end

      if 0 >= itemstack.count then break end

      if v1_struct.entity.surface == alert_target.surface then break end
      if v1_struct.entity.force ~= alert_target.force then break end

      local available = v1_struct.entity.get_item_count(itemstack.name)
      if available > 0 then
        for _, network in ipairs(networks) do
          local inserted = network.insert({name = itemstack.name, count = math.min(itemstack.count, available)}, 'storage')
          if inserted > 0 then
            Handler.shoot(v1_struct)
            v1_struct.entity.remove_item({name = itemstack.name, count = inserted})
            -- available = available - inserted
            itemstack.count = itemstack.count - inserted
            break -- succesfully delivered any amount to a network providing construction coverage
          end

          if inserted == 0 and #network.storages > 0 then
            -- local cell = network.cells[math.random(1, #network.cells)]
            local cell = network.find_cell_closest_to(v1_struct.entity.position)
            for _, connected_player in ipairs(game.connected_players) do
              if connected_player.force == alert_target.force then
                connected_player.add_alert(cell.owner, defines.alert_type.no_storage)
              end
            end
          end
        end
      end

    end
  end

  ::undeliverable::

  -- any items we were not able to satisfy from the buffer chest will move onto the next cycle
  for _, itemstack in ipairs(items_to_place_this) do
    if itemstack.count > 0 then
      global.missing_items[itemstack.name] = (global.missing_items[itemstack.name] or 0) + itemstack.count
    end
  end
end

function Handler.on_tick(event)
  -- log('#alert_targets = ' .. table_size(global.alert_targets))
  local i = 1
  for unit_number, alert_target in pairs(global.alert_targets) do
    global.alert_targets[unit_number] = nil
    if alert_target.valid then
      Handler.handle_construction_alert(alert_target)
      i = i + 1
      if i > global.alert_targets_per_tick then return end
    end
  end

  if not global.alert_targets_emptied then
    -- all the alerts from the last 10 seconds have been processed
    global.alert_targets_emptied = true
    -- game.print(serpent.line(global.missing_items))
    Handler.update_all_logistic_requests(global.missing_items)

    global.trash_unrequested_queue = {}
    for unit_number, v1_struct in pairs(global.v1_structs) do
      table.insert(global.trash_unrequested_queue, v1_struct)
    end
    Handler.shuffle_array_in_place(global.trash_unrequested_queue)
    return
  else

  -- idle ticks (not guaranteed, e.g. if there is exactly a multiple of 600)

    local v1_struct = table.remove(global.trash_unrequested_queue)
    if v1_struct and v1_struct.entity.valid then
      Handler.trash_unrequested(v1_struct)
    end
  end
end

function Handler.keys_highest_to_lowest_value(dict)
  local keys = {}
  for key in pairs(dict) do
    table.insert(keys, key)
  end
  table.sort(keys, function(a, b) return dict[a] > dict[b] end)
  return keys
end

function Handler.update_all_logistic_requests(missing_items)
  local keys = Handler.keys_highest_to_lowest_value(missing_items)

  for unit_number, v1_struct in pairs(global.v1_structs) do
    if v1_struct.entity.valid then
      -- todo: set on one, then copy paste to all the others with entity.copy_settings()

      for i = 1, v1_struct.entity.request_slot_count, 1 do
        v1_struct.entity.clear_request_slot(i)
      end

      for _, name in ipairs(keys) do
        v1_struct.entity.set_request_slot({name = name, count = missing_items[name]}, v1_struct.entity.request_slot_count + 1)
      end
    end
  end
end

function Handler.update_logistic_requests(missing_items, v1_struct)
  local keys = Handler.keys_highest_to_lowest_value(missing_items)

  for i = 1, v1_struct.entity.request_slot_count, 1 do
    v1_struct.entity.clear_request_slot(i)
  end

  for _, name in ipairs(keys) do
    v1_struct.entity.set_request_slot({name = name, count = missing_items[name]}, v1_struct.entity.request_slot_count + 1)
  end
end

-- items need to make it back to the storage if they linger, i don't feel like dumping them on the ground or adding an active provider to the structure.
function Handler.trash_unrequested(v1_struct)
  local logistic_network = v1_struct.entity.logistic_network
  if not logistic_network then return end

  -- avoid teleporting items back to storage if observed :o
  for _, connected_player in ipairs(game.connected_players) do
    if connected_player.opened == v1_struct.entity then return end
    if connected_player.selected == v1_struct.entity then return end
  end

  local inventory = v1_struct.entity.get_inventory(defines.inventory.chest)
  for name, count in pairs(inventory.get_contents()) do
    if not global.missing_items[name] then
      local inserted = logistic_network.insert({name = name, count = count}, 'storage') -- we don't want stealth inserts to deliver to requesters
      if inserted > 0 then inventory.remove({name = name, count = inserted}) end
    end
  end

  inventory.sort_and_merge()
end

return Handler
