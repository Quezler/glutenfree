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

local function organize_combinator(entity)
  local parameters = {}

  local values = {}
  values['item'] = {}
  values['fluid'] = {}
  values['virtual'] = {}
  for _, parameter in ipairs(entity.get_control_behavior().parameters) do
    if parameter.signal.name then
      values[parameter.signal.type][parameter.signal.name] = (values[parameter.signal.type][parameter.signal.name] or 0) + parameter.count
    end
  end

  for signal_type, name_to_slot in pairs(global.position) do
    for name, slot in pairs(name_to_slot) do
      table.insert(parameters, {
        signal = {type = signal_type, name = name},
        count = (values[signal_type][name] or 0),
        index = slot
      })
    end
  end

  entity.get_control_behavior().parameters = parameters

  entity.surface.create_entity{name = 'tutorial-flying-text', position = entity.position, text = '[entity=character]'}
end

local function on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination

  organize_combinator(entity)
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

script.on_event(defines.events.on_gui_closed, function(event)
  if event.gui_type == defines.gui_type.entity then
    if event.entity.name == 'character-combinator' then
      organize_combinator(event.entity)
    end
  end
end)

local function on_configuration_changed(event)
  global.position = {}
  global.position['item'] = {}
  global.position['fluid'] = {}
  global.position['virtual'] = {}

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

  local slot = 1

  for _, item_group in pairs(game.item_group_prototypes) do
    local slot_was = slot
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
          global.position[signal_type][child.name] = slot
          slot = slot + 1
        end
      end
      slot = next_10(slot-1) + 1
    end

    -- skip adding a row between groups if none if its sub groups added anything
    if slot > slot_was then
      slot = next_10(slot) + 1
    end
  end
end

script.on_init(on_configuration_changed)
script.on_configuration_changed(on_configuration_changed)
