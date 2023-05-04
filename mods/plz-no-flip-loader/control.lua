local function spill(event)
  local entity = event.entity or event.destination

  if entity == nil then return end
  if not (entity.type == "loader-1x1" or entity.type == "loader") then return end
  if entity.loader_type ~= "output" then return end

  local whitelisted = {}
  for i = 1, entity.filter_slot_count do
    if entity.get_filter(i) then
      whitelisted[entity.get_filter(i)] = true
    end
  end

  -- nothing is whitelisted, so every item is allowed
  if table_size(whitelisted) == 0 then return end

  for i = 1, entity.get_max_transport_line_index() do

    local line = entity.get_transport_line(i)
    -- #line 0-1 for loader1x1 & 0-1-2 for loader

    -- looped in reverse since after we remove the 1st item the 2nd moves up
    for j = #line, 1, -1 do
      local itemstack = line[j]
      if itemstack.count > 1 then error('itemstack.count > 1') end

      if not whitelisted[itemstack.name] then
        if entity.loader_container and entity.loader_container.insert(itemstack) == 1 then
          -- item returned to the container
        else
          -- failed to return item so spill it
          entity.surface.spill_item_stack(entity.position, itemstack, false, entity.force, false)
        end

        line.remove_item(itemstack)
      end
    end

  end
end

script.on_event(defines.events.on_gui_closed, spill)
script.on_event(defines.events.on_entity_settings_pasted, spill)
