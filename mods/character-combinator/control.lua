local signal_type_for = {
  LuaItemPrototype = 'item',
  LuaFluidPrototype = 'fluid',
  LuaVirtualSignalPrototype = 'virtual',
}

local function next_10(i)
  repeat
    if (i % 10) == 0 then return i end
    i = i + 1
  until(false)
end

-- local function is_prototype_hidden(prototype)
--   for _, flag in i
-- end

local function on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination

  -- item groups and their subgroups seem to already be ordered by their order string, unexpected but neat.
  -- for _, item_group in pairs(game.item_group_prototypes) do
  --   game.print(item_group.name)
  --   for _, item_subgroup in ipairs(item_group.subgroups) do
  --     game.print(item_subgroup.name)
  --   end
  --   break
    
  -- end

  local subgroup_children = {}
  for _, item_group in pairs(game.item_group_prototypes) do
    for _, item_subgroup in ipairs(item_group.subgroups) do
      subgroup_children[item_subgroup.name] = {}
    end
  end

  for _, item in pairs(game.item_prototypes) do
    table.insert(subgroup_children[item.subgroup.name], item)
  end
  for _, fluid in pairs(game.fluid_prototypes) do
    table.insert(subgroup_children[fluid.subgroup.name], fluid)
  end
  for _, signal in pairs(game.virtual_signal_prototypes) do
    table.insert(subgroup_children[signal.subgroup.name], signal)
  end

  local parameters = {}
  local slot = 1

  for _, item_group in pairs(game.item_group_prototypes) do
    for _, item_subgroup in ipairs(item_group.subgroups) do
      local children = subgroup_children[item_subgroup.name]
      for _, child in ipairs(children) do
        local signal_type = signal_type_for[child.object_name]
        if signal_type == 'item' and child.flags and child.flags['hidden'] then
          -- nothing
        elseif signal_type == 'fluid' and child.hidden then
          -- nothing
        elseif signal_type == 'virtual' and child.special then
          -- nothing
        else
          table.insert(parameters, {
            signal = {type = signal_type, name = child.name},
            count = 0,
            index = slot
          })
          slot = slot + 1
        end
      end
      slot = next_10(slot-1) + 1
    end
    slot = next_10(slot) + 1
  end

  entity.get_control_behavior().parameters = parameters
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    {filter = 'name', name = 'character-combinator'},
  })
end
