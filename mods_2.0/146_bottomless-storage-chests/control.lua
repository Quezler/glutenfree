local mod = {}

script.on_init(function ()
  storage.structs = {}
  storage.deathrattles = {}
end)

mod.on_created_entity_filters = {
  {filter = "name", name = "bottomless-storage-chest"},
}

mod.on_created_entity = function(event)
  local entity = event.entity or event.destination

  storage.structs[entity.unit_number] = {
    index = entity.unit_number,
    entity = entity,
  }

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {}

  mod.tick_struct(storage.structs[entity.unit_number])
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, mod.on_created_entity, mod.on_created_entity_filters)
end

local function add_to_contents(contents, item_with_quality_count)
  for _, content in ipairs(contents) do
    if content.name == item_with_quality_count.name and content.quality == item_with_quality_count.quality then
      content.count = content.count + item_with_quality_count.count
      return
    end
  end

  table.insert(contents, item_with_quality_count)
end

local function get_non_bottomless_storage_contents(logistic_network)
  local contents = {}

  for _, storage in ipairs(logistic_network.storages) do
    if storage.name ~= "bottomless-storage-chest" then
      for _, item_with_quality_count in ipairs(storage.get_inventory(defines.inventory.chest).get_contents()) do
        add_to_contents(contents, item_with_quality_count)
      end
    end
  end

  return contents
end

--- @param contents ItemWithQualityCounts
--- @return ItemWithQualityCount?
local function get_highest_from_contents(contents)
  local highest = nil

  for _, item_with_quality_count in ipairs(contents) do
    if highest == nil or item_with_quality_count.count > highest.count then
      highest = item_with_quality_count
    end
  end

  return highest
end

local function deconstruct_non_bottomless_storage_chests_with(logistic_network, item_with_quality_count, destination)
  for _, storage in ipairs(logistic_network.storages) do
    if storage.name ~= "bottomless-storage-chest" then
      if storage.get_inventory(defines.inventory.chest).get_item_count(item_with_quality_count) > 0 then
        storage.order_deconstruction(storage.force, destination.last_user, 1)
      end
    end
  end
end

mod.tick_struct = function(struct)
  local logistic_network = struct.entity.logistic_network
  if not logistic_network then return end

  local item_to_hoard = nil

  if item_to_hoard == nil then
    local stack = struct.entity.get_inventory(defines.inventory.chest)[1]
    if stack and stack.valid_for_read then
      item_to_hoard = {name = stack.name, quality = stack.quality}
    end
  end

  if item_to_hoard == nil then
    local filter = struct.entity.get_filter(1)
    if filter then
      item_to_hoard = {name = filter.name, quality = filter.quality}
    end
  end

  if item_to_hoard == nil then
    local item_with_quality_count = get_highest_from_contents(get_non_bottomless_storage_contents(logistic_network))
    if item_with_quality_count then
      item_to_hoard = {name = item_with_quality_count.name, quality = item_with_quality_count.quality}
    end
  end

  -- game.print(serpent.line(item_to_hoard))

  if item_to_hoard ~= nil then
    if logistic_network.remove_item(item_to_hoard, "storage") > 0 then
      assert(struct.entity.get_inventory(defines.inventory.chest).insert(item_to_hoard) > 0)
      deconstruct_non_bottomless_storage_chests_with(logistic_network, item_to_hoard, struct.entity)
    end
  end
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    local struct = storage.structs[event.useful_id]
    if struct then storage.structs[event.useful_id] = nil
      --
    end
  end
end)
