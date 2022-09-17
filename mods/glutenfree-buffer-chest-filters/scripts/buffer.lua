local buffer = {}

function buffer.on_gui_closed(event)
  if not settings.global["buffer-chest-filters-spaceship-mode"].value then return end

  if event.gui_type ~= defines.gui_type.entity then return end

  local entity = event.entity
  if entity.name ~= "logistic-chest-buffer" then return end

  local inventory = entity.get_inventory(defines.inventory.chest)
  local size = #inventory

  -- clear all filters
  for slot = 1, size do
    inventory.set_filter(slot, nil)
  end

  if entity.get_control_behavior() then
    if entity.get_control_behavior().circuit_mode_of_operation == defines.control_behavior.logistic_container.circuit_mode_of_operation.set_requests then
      if #entity.circuit_connected_entities.red > 0 or #entity.circuit_connected_entities.green > 0 then
        return -- request filters are set by a circuit signal, and at least one wire is connected, skip
      end
    end
  end

  -- populate new filters
  local next_filter_slot = 1
  local buffer = entity.get_logistic_point(defines.logistic_member_index.logistic_container)
  for _, filter in ipairs(buffer.filters or {}) do
    local stack_size = game.item_prototypes[filter.name].stack_size
    local slots_required = math.ceil(filter.count / stack_size)

    for slot = 1, slots_required do
      if size >= next_filter_slot then
        inventory.set_filter(next_filter_slot, filter.name)
        next_filter_slot = next_filter_slot + 1
      end
    end
  end

  -- do a courtesy sort
  inventory.sort_and_merge()

  -- sort the stranglers
  for slot = 1, size do
    local item = inventory[slot]
    if item and item.valid_for_read then
      local filter = inventory.get_filter(slot)
      -- should this item should be evicted?
      if filter and item.name ~= filter then

        -- move the current stack into a pocket dimension
        local bag_of_holding = game.create_inventory(1)
        bag_of_holding[1].transfer_stack(inventory[slot])

        -- try to insert it into a slot that does allow it
        local spill = bag_of_holding[1].count - inventory.insert(bag_of_holding[1])

        -- and if there are leftover items, just spill them
        if spill > 0 then
          bag_of_holding[1].count = spill
          entity.surface.spill_item_stack(entity.position, bag_of_holding[1], false, entity.force, false)
        end

        bag_of_holding.destroy()
      end
    end
  end
end

return buffer
