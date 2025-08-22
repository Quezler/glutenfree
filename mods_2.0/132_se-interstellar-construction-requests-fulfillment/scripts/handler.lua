local Util = require("__space-exploration-scripts__.util")
local Meteor = require("__space-exploration-scripts__.meteor")
--
local Handler = {}

function Handler.on_init(event)
  storage.v1_structs = {}
  storage.v1_unit_numbers = {}

  storage.alert_targets = {}
  storage.alert_targets_emptied = false
  storage.alert_targets_per_tick = 1

  storage.missing_items = {} -- holds missing items for all forces, though the code will only shoot if the forces match
  storage.trash_unrequested_queue = {}

  Handler.regenerate_item_request_proxy_whitelist()
end

function Handler.on_configuration_changed(event)
  storage.structs = nil
  storage.deck = nil
  storage.pile = nil
  storage.handled_alerts = nil
  storage.deathrattles = nil
  storage.children_to_kill = nil
  storage.rich_text_name_for_destination_surface = nil
  --
  storage.v1_structs = storage.v1_structs or {}
  storage.v1_unit_numbers = storage.v1_unit_numbers or {}

  storage.alert_targets = storage.alert_targets or {}
  storage.alert_targets_emptied = storage.alert_targets_emptied or false
  storage.alert_targets_per_tick = storage.alert_targets_per_tick or 1

  storage.missing_items = storage.missing_items or {}
  storage.trash_unrequested_queue = storage.trash_unrequested_queue or {}

  Handler.regenerate_item_request_proxy_whitelist()
end

local entity_name_bypasses_proxy_whitelist = {
  ["magic-huts--container-1"] = true,
  ["magic-huts--container-2"] = true,
  ["magic-huts--container-3"] = true,
  ["magic-huts--container-4"] = true,
  ["magic-huts--container-5"] = true,
  ["magic-huts--container-6"] = true,
  ["glutenfree-equipment-train-stop-template-container"] = true,
}
function Handler.regenerate_item_request_proxy_whitelist()
  storage.item_request_proxy_whitelist = {}
  local module_prototypes = prototypes.get_item_filtered({{filter = "type", type = "module"}})
  for module_name, module_prototype in pairs(module_prototypes) do
    storage.item_request_proxy_whitelist[module_name] = true
  end
end

function Handler.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination

  local v1_struct = {
    unit_number = entity.unit_number,
    entity = entity,
    barrel = 0,
  }

  storage.v1_structs[entity.unit_number] = v1_struct
  table.insert(storage.v1_unit_numbers, v1_struct.unit_number)

  Handler.update_logistic_requests(storage.missing_items, v1_struct)
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
    for _, item in ipairs(alert_target.item_requests) do
      if storage.item_request_proxy_whitelist[item.name] or entity_name_bypasses_proxy_whitelist[alert_target.proxy_target.name] then
        table.insert(items_to_place_this, {name = item.name, count = item.count})
      end
    end
    return items_to_place_this
  elseif alert_target.get_upgrade_target() then
    return alert_target.get_upgrade_target().items_to_place_this
  elseif alert_target.type == "cliff" then
    return {{name = "cliff-explosives", count = 1}}
  elseif 1 > alert_target.get_health_ratio() then
   return {{name = "repair-pack", count = 1}}
  end
end

function Handler.shuffle_array_in_place(t)
  for i = #t, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
  end
end

-- local function logistic_network_is_personal(logistic_network)
--   local cells = logistic_network.cells
--   return #cells == 1 and cells[1].owner.type == "character"
-- end

function Handler.handle_construction_alert(alert_target)
  local items_to_place_this = Handler.items_to_place_this(alert_target)
  if not items_to_place_this then return end -- upgrade canceled?

  local alert_target_force = alert_target.force
  if alert_target.force.name == "neutral" and alert_target.type == "cliff" then alert_target_force = game.forces["player"] end

  Handler.shuffle_array_in_place(storage.v1_unit_numbers)

  for _, itemstack in ipairs(items_to_place_this) do
    for index, unit_number in ipairs(storage.v1_unit_numbers) do
      local v1_struct = storage.v1_structs[unit_number]
      if not v1_struct.entity.valid then
        storage.v1_structs[unit_number] = nil
        table.remove(storage.v1_unit_numbers, index)
        break
      end

      if 0 >= itemstack.count then break end

      if v1_struct.entity.surface == alert_target.surface then break end
      if v1_struct.entity.force ~= alert_target_force then break end

      local available = v1_struct.entity.get_item_count(itemstack.name)
      if available > 0 then
        local count = math.min(itemstack.count, available)
        local disposable_construction_robot = alert_target.surface.create_entity{
          name = "disposable-construction-robot",
          force = alert_target_force,
          position = alert_target.position,
        }
        local cargo = disposable_construction_robot.get_inventory(defines.inventory.robot_cargo)[1]
        cargo.set_stack({name = itemstack.name, count = count})
        v1_struct.entity.remove_item({name = itemstack.name, count = cargo.count})
      end
    end
  end

  -- any items we were not able to satisfy from the buffer chest will move onto the next cycle
  for _, itemstack in ipairs(items_to_place_this) do
    if itemstack.count > 0 then
      storage.missing_items[itemstack.name] = (storage.missing_items[itemstack.name] or 0) + itemstack.count
    end
  end
end

function Handler.on_tick(event)
  -- log("#alert_targets = " .. table_size(storage.alert_targets))
  local i = 1
  for unit_number, alert_target in pairs(storage.alert_targets) do
    storage.alert_targets[unit_number] = nil
    if alert_target.valid then
      Handler.handle_construction_alert(alert_target)
      i = i + 1
      if i > storage.alert_targets_per_tick then return end
    end
  end

  if not storage.alert_targets_emptied then
    -- all the alerts from the last 10 seconds have been processed
    storage.alert_targets_emptied = true
    -- game.print(serpent.line(storage.missing_items))
    Handler.update_all_logistic_requests(storage.missing_items)

    storage.trash_unrequested_queue = {}
    for unit_number, v1_struct in pairs(storage.v1_structs) do
      table.insert(storage.trash_unrequested_queue, v1_struct)
    end
    Handler.shuffle_array_in_place(storage.trash_unrequested_queue)
    return
  else

  -- idle ticks (not guaranteed, e.g. if there is exactly a multiple of 600)

    local v1_struct = table.remove(storage.trash_unrequested_queue)
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

  for unit_number, v1_struct in pairs(storage.v1_structs) do
    if v1_struct.entity.valid then
      -- todo: set on one, then copy paste to all the others with entity.copy_settings()

      v1_struct.entity.get_requester_point().trash_not_requested = true
      local sections = v1_struct.entity.get_logistic_sections()
      sections.remove_section(1)
      sections.remove_section(1)

      local section = sections.add_section()

      for i, name in ipairs(keys) do
        section.set_slot(i, {value = {type = "item", name = name, quality = "normal"}, min = missing_items[name]})
      end
    end
  end
end

function Handler.update_logistic_requests(missing_items, v1_struct)
  local keys = Handler.keys_highest_to_lowest_value(missing_items)

  v1_struct.entity.get_requester_point().trash_not_requested = true
  local sections = v1_struct.entity.get_logistic_sections()
  sections.remove_section(1)
  sections.remove_section(1)

  local section = sections.add_section()

  for i, name in ipairs(keys) do
    section.set_slot(i, {value = {type = "item", name = name, quality = "normal"}, min = missing_items[name]})
  end
end

-- items need to make it back to the storage if they linger, i don"t feel like dumping them on the ground or adding an active provider to the structure.
function Handler.trash_unrequested(v1_struct)
  local logistic_network = v1_struct.entity.logistic_network
  if not logistic_network then return end

  -- avoid teleporting items back to storage if observed :o
  for _, connected_player in ipairs(game.connected_players) do
    if connected_player.opened == v1_struct.entity then return end
    if connected_player.selected == v1_struct.entity then return end
  end

  local inventory = v1_struct.entity.get_inventory(defines.inventory.chest)
  for _, item in ipairs(inventory.get_contents()) do
    if not storage.missing_items[item.name] then
      local inserted = logistic_network.insert({name = item.name, count = item.count}, "storage") -- we don"t want stealth inserts to deliver to requesters
      if inserted > 0 then inventory.remove({name = item.name, count = inserted}) end
    end
  end

  inventory.sort_and_merge()
end

return Handler
